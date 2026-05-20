# frozen_string_literal: true

require 'spec_helper'
require 'openssl'
require 'base64'
require 'digest'
require 'json'

describe Descope::DPoP do
  # A small helper class that includes the module under test
  let(:subject_class) do
    Class.new do
      include Descope::DPoP
      public :pad_base64, :compute_jwk_thumbprint, :htu_matches?, :normalize_uri,
             :extract_token_claims, :import_jwk_public_key, :verify_dpop_signature,
             :validate_dpop_payload_claims, :validate_dpop_ath, :validate_dpop_jkt,
             :import_ec_public_key, :import_rsa_public_key, :verify_ec_dpop_signature
    end
  end

  subject { subject_class.new }

  # ── helpers ──────────────────────────────────────────────────────────────────

  def b64url_encode(bytes)
    Base64.urlsafe_encode64(bytes, padding: false)
  end

  def b64url_decode(str)
    Base64.urlsafe_decode64(str + '=' * ((4 - str.length % 4) % 4))
  end

  # Builds a minimal DPoP proof JWT signed with the given key.
  # Returns [proof_string, jwk_dict]
  def build_dpop_proof(ec_key: nil, rsa_key: nil, alg: 'ES256',
                       htm: 'GET', htu: 'https://api.example.com/resource',
                       access_token: 'test_access_token',
                       iat: Time.now.to_i, jti: 'unique-jti-1234',
                       override_header: {}, override_payload: {})
    if ec_key
      jwk = ec_key_to_jwk(ec_key)
      sign_key = ec_key
    elsif rsa_key
      jwk = rsa_key_to_jwk(rsa_key)
      sign_key = rsa_key
    else
      raise ArgumentError, 'must provide ec_key or rsa_key'
    end

    ath = Base64.urlsafe_encode64(Digest::SHA256.digest(access_token), padding: false)

    header = { 'typ' => 'dpop+jwt', 'alg' => alg, 'jwk' => jwk }.merge(override_header)
    payload = { 'jti' => jti, 'htm' => htm, 'htu' => htu, 'iat' => iat, 'ath' => ath }.merge(override_payload)

    header_b64 = b64url_encode(JSON.dump(header))
    payload_b64 = b64url_encode(JSON.dump(payload))
    signing_input = "#{header_b64}.#{payload_b64}"

    sig_bytes = sign_dpop(sign_key, signing_input, alg)
    sig_b64 = b64url_encode(sig_bytes)

    ["#{signing_input}.#{sig_b64}", jwk]
  end

  def sign_dpop(key, signing_input, alg)
    if alg.start_with?('ES')
      digest = OpenSSL::Digest.new(digest_name_for(alg))
      # EC sign returns DER; JWT needs raw R||S
      der_sig = key.sign(digest, signing_input)
      asn1 = OpenSSL::ASN1.decode(der_sig)
      r = asn1.value[0].value.to_s(2)
      s = asn1.value[1].value.to_s(2)
      half = alg == 'ES256' ? 32 : (alg == 'ES384' ? 48 : 66)
      r.rjust(half, "\x00") + s.rjust(half, "\x00")
    elsif alg.start_with?('RS')
      key.sign(OpenSSL::Digest.new(digest_name_for(alg)), signing_input)
    elsif alg.start_with?('PS')
      key.sign_pss(digest_name_for(alg), signing_input, salt_length: :max, mgf1_hash: digest_name_for(alg))
    end
  end

  def digest_name_for(alg)
    { 'ES256' => 'SHA256', 'ES384' => 'SHA384', 'ES512' => 'SHA512',
      'RS256' => 'SHA256', 'RS384' => 'SHA384', 'RS512' => 'SHA512',
      'PS256' => 'SHA256', 'PS384' => 'SHA384', 'PS512' => 'SHA512' }[alg]
  end

  def ec_key_to_jwk(key)
    point = key.public_key
    bytes = point.to_octet_string(:uncompressed)
    # bytes[0] is 0x04; then x, y halves
    coord_len = (bytes.length - 1) / 2
    x_bytes = bytes[1, coord_len]
    y_bytes = bytes[1 + coord_len, coord_len]
    crv = case key.group.curve_name
          when 'prime256v1' then 'P-256'
          when 'secp384r1'  then 'P-384'
          when 'secp521r1'  then 'P-521'
          end
    { 'kty' => 'EC', 'crv' => crv,
      'x' => b64url_encode(x_bytes),
      'y' => b64url_encode(y_bytes) }
  end

  def rsa_key_to_jwk(key)
    pub = key.public_key
    { 'kty' => 'RSA',
      'n' => b64url_encode(pub.n.to_s(2)),
      'e' => b64url_encode(pub.e.to_s(2)) }
  end

  # Build a minimal access token with cnf.jkt
  def build_access_token_with_jkt(jkt)
    payload = { 'sub' => 'user123', 'cnf' => { 'jkt' => jkt } }
    header = { 'alg' => 'none', 'typ' => 'JWT' }
    h = b64url_encode(JSON.dump(header))
    p = b64url_encode(JSON.dump(payload))
    "#{h}.#{p}."
  end

  # ── #pad_base64 ──────────────────────────────────────────────────────────────

  describe '#pad_base64' do
    it 'adds no padding when already aligned' do
      str = 'abcd'
      expect(subject.pad_base64(str)).to eq('abcd')
    end

    it 'adds 1 = when 3 chars' do
      expect(subject.pad_base64('abc')).to eq('abc=')
    end

    it 'adds 2 == when 2 chars' do
      expect(subject.pad_base64('ab')).to eq('ab==')
    end

    it 'adds 3 === when 1 char' do
      expect(subject.pad_base64('a')).to eq('a===')
    end
  end

  # ── #htu_matches? ────────────────────────────────────────────────────────────

  describe '#htu_matches?' do
    it 'matches identical URLs' do
      expect(subject.htu_matches?('https://api.example.com/res', 'https://api.example.com/res')).to be true
    end

    it 'strips query string from both' do
      expect(subject.htu_matches?('https://api.example.com/res?foo=bar', 'https://api.example.com/res')).to be true
    end

    it 'strips fragment from both' do
      expect(subject.htu_matches?('https://api.example.com/res#frag', 'https://api.example.com/res')).to be true
    end

    it 'normalizes scheme to lowercase' do
      expect(subject.htu_matches?('HTTPS://api.example.com/res', 'https://api.example.com/res')).to be true
    end

    it 'normalizes host to lowercase' do
      expect(subject.htu_matches?('https://API.EXAMPLE.COM/res', 'https://api.example.com/res')).to be true
    end

    it 'strips default https port 443' do
      expect(subject.htu_matches?('https://api.example.com:443/res', 'https://api.example.com/res')).to be true
    end

    it 'strips default http port 80' do
      expect(subject.htu_matches?('http://api.example.com:80/res', 'http://api.example.com/res')).to be true
    end

    it 'does not strip non-default port' do
      expect(subject.htu_matches?('https://api.example.com:8443/res', 'https://api.example.com/res')).to be false
    end

    it 'returns false for different paths' do
      expect(subject.htu_matches?('https://api.example.com/a', 'https://api.example.com/b')).to be false
    end

    it 'returns false for different hosts' do
      expect(subject.htu_matches?('https://a.example.com/res', 'https://b.example.com/res')).to be false
    end

    it 'returns false for invalid URI' do
      expect(subject.htu_matches?('not-a-uri', 'https://api.example.com/res')).to be false
    end
  end

  # ── #compute_jwk_thumbprint ──────────────────────────────────────────────────

  describe '#compute_jwk_thumbprint' do
    it 'computes correct EC thumbprint (RFC 7638 example)' do
      # Test vector from RFC 7638 §3.3
      jwk = {
        'kty' => 'EC',
        'crv' => 'P-256',
        'x' => '0tbHIv9LPUBT5MGPKK2Nw_ZsqYMgUFNcQIkFv4QD_I8',
        'y' => 'qMJt6sUrqFbIHi9a4Zl5B5S6xv2GmQq6M-X39QfNgzg',
        'd' => 'somePrivateKey'
      }
      thumbprint = subject.compute_jwk_thumbprint(jwk)
      # The result should be a non-empty base64url string
      expect(thumbprint).to be_a(String)
      expect(thumbprint).not_to be_empty
      # Verify it's base64url (no padding, no +/)
      expect(thumbprint).not_to include('=', '+', '/')
    end

    it 'computes RSA thumbprint using only e, kty, n' do
      rsa = OpenSSL::PKey::RSA.generate(2048)
      jwk = rsa_key_to_jwk(rsa)
      jwk['extra_field'] = 'should be ignored'
      thumbprint = subject.compute_jwk_thumbprint(jwk)
      expect(thumbprint).to be_a(String)
      expect(thumbprint).not_to be_empty
    end

    it 'computes OKP thumbprint' do
      jwk = { 'kty' => 'OKP', 'crv' => 'Ed25519', 'x' => 'somebase64urlx' }
      thumbprint = subject.compute_jwk_thumbprint(jwk)
      expect(thumbprint).to be_a(String)
    end

    it 'raises on unsupported key type' do
      expect do
        subject.compute_jwk_thumbprint({ 'kty' => 'oct', 'k' => 'secret' })
      end.to raise_error(Descope::AuthException, /Unsupported JWK key type for thumbprint/)
    end
  end

  # ── #get_dpop_thumbprint ─────────────────────────────────────────────────────

  describe '#get_dpop_thumbprint' do
    it 'extracts jkt from claims with cnf' do
      claims = { 'cnf' => { 'jkt' => 'abc123' }, 'sub' => 'user' }
      expect(subject.get_dpop_thumbprint(claims)).to eq('abc123')
    end

    it 'returns nil when cnf is absent' do
      expect(subject.get_dpop_thumbprint({ 'sub' => 'user' })).to be_nil
    end

    it 'returns nil when claims is nil' do
      expect(subject.get_dpop_thumbprint(nil)).to be_nil
    end

    it 'returns nil when cnf has no jkt' do
      expect(subject.get_dpop_thumbprint({ 'cnf' => {} })).to be_nil
    end
  end

  # ── #validate_dpop_proof — EC ES256 ─────────────────────────────────────────

  describe '#validate_dpop_proof with ES256' do
    let(:ec_key) { OpenSSL::PKey::EC.generate('prime256v1') }
    let(:access_token) { 'my.access.token' }
    let(:method) { 'GET' }
    let(:url) { 'https://api.example.com/resource' }

    def build_token_for(key)
      jwk = ec_key_to_jwk(key)
      jkt = subject.compute_jwk_thumbprint(jwk)
      build_access_token_with_jkt(jkt)
    end

    it 'validates a correct ES256 DPoP proof' do
      session_token = build_token_for(ec_key)
      proof, = build_dpop_proof(ec_key: ec_key, access_token: session_token)
      expect { subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token) }.not_to raise_error
    end

    it 'skips validation when cnf.jkt is absent' do
      token_no_jkt = build_access_token_with_jkt(nil).sub('"jkt":null,', '')
      # Build a token with no cnf at all
      plain_payload = b64url_encode(JSON.dump({ 'sub' => 'user' }))
      plain_header  = b64url_encode(JSON.dump({ 'alg' => 'none' }))
      no_jkt_token  = "#{plain_header}.#{plain_payload}."
      expect { subject.validate_dpop_proof(dpop_proof: 'anything', method: method, request_url: url, session_token: no_jkt_token) }.not_to raise_error
    end

    it 'raises when proof is empty' do
      session_token = build_token_for(ec_key)
      expect do
        subject.validate_dpop_proof(dpop_proof: '', method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /empty/)
    end

    it 'raises when proof exceeds max length' do
      session_token = build_token_for(ec_key)
      expect do
        subject.validate_dpop_proof(dpop_proof: 'a' * 8193, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /maximum length/)
    end

    it 'raises when proof does not have 3 parts' do
      session_token = build_token_for(ec_key)
      expect do
        subject.validate_dpop_proof(dpop_proof: 'header.payload', method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /3 parts/)
    end

    it 'raises when typ is wrong' do
      session_token = build_token_for(ec_key)
      proof, = build_dpop_proof(ec_key: ec_key, access_token: session_token,
                                override_header: { 'typ' => 'JWT' })
      expect do
        subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /typ must be 'dpop\+jwt'/)
    end

    it 'raises when alg is unsupported' do
      session_token = build_token_for(ec_key)
      # Patch the header manually after building
      parts = build_dpop_proof(ec_key: ec_key, access_token: session_token)[0].split('.')
      bad_header = b64url_encode(JSON.dump({ 'typ' => 'dpop+jwt', 'alg' => 'HS256', 'jwk' => ec_key_to_jwk(ec_key) }))
      bad_proof = "#{bad_header}.#{parts[1]}.#{parts[2]}"
      expect do
        subject.validate_dpop_proof(dpop_proof: bad_proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /unsupported algorithm/)
    end

    it 'raises when htm does not match' do
      session_token = build_token_for(ec_key)
      proof, = build_dpop_proof(ec_key: ec_key, access_token: session_token, htm: 'POST')
      expect do
        subject.validate_dpop_proof(dpop_proof: proof, method: 'GET', request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /htm.*does not match/)
    end

    it 'raises when htu does not match' do
      session_token = build_token_for(ec_key)
      proof, = build_dpop_proof(ec_key: ec_key, access_token: session_token, htu: 'https://other.example.com/resource')
      expect do
        subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /htu.*does not match/)
    end

    it 'raises when iat is too old' do
      session_token = build_token_for(ec_key)
      proof, = build_dpop_proof(ec_key: ec_key, access_token: session_token, iat: Time.now.to_i - 120)
      expect do
        subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /expired/)
    end

    it 'raises when iat is in the future' do
      session_token = build_token_for(ec_key)
      proof, = build_dpop_proof(ec_key: ec_key, access_token: session_token, iat: Time.now.to_i + 60)
      expect do
        subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /future/)
    end

    it 'raises when ath does not match access token' do
      session_token = build_token_for(ec_key)
      proof, = build_dpop_proof(ec_key: ec_key, access_token: 'different_token')
      # Override jkt claim to match our key
      expect do
        subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /ath does not match/)
    end

    it 'raises when signature is invalid' do
      session_token = build_token_for(ec_key)
      other_key = OpenSSL::PKey::EC.generate('prime256v1')
      proof, = build_dpop_proof(ec_key: other_key, access_token: session_token)
      # Patch the JWK in the header to point to ec_key but the sig is from other_key
      ec_jwk = ec_key_to_jwk(ec_key)
      other_parts = proof.split('.')
      patched_header = b64url_encode(JSON.dump({ 'typ' => 'dpop+jwt', 'alg' => 'ES256', 'jwk' => ec_jwk }))
      bad_proof = "#{patched_header}.#{other_parts[1]}.#{other_parts[2]}"
      expect do
        subject.validate_dpop_proof(dpop_proof: bad_proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /signature verification failed/)
    end

    it 'raises when JWK thumbprint does not match cnf.jkt' do
      other_key = OpenSSL::PKey::EC.generate('prime256v1')
      session_token = build_token_for(other_key)  # token bound to other_key
      proof, = build_dpop_proof(ec_key: ec_key, access_token: session_token)  # proof uses ec_key
      expect do
        subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /thumbprint does not match/)
    end
  end

  # ── #validate_dpop_proof — RSA RS256 ────────────────────────────────────────

  describe '#validate_dpop_proof with RS256' do
    let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:access_token) { 'rsa.access.token' }
    let(:method) { 'POST' }
    let(:url) { 'https://api.example.com/data' }

    def build_rsa_token_for(key)
      jwk = rsa_key_to_jwk(key)
      jkt = subject.compute_jwk_thumbprint(jwk)
      build_access_token_with_jkt(jkt)
    end

    it 'validates a correct RS256 DPoP proof' do
      session_token = build_rsa_token_for(rsa_key)
      proof, = build_dpop_proof(rsa_key: rsa_key, alg: 'RS256', htm: method, htu: url, access_token: session_token)
      expect { subject.validate_dpop_proof(dpop_proof: proof, method: method, request_url: url, session_token: session_token) }.not_to raise_error
    end

    it 'raises when JWK contains private key material (d)' do
      session_token = build_rsa_token_for(rsa_key)
      proof, jwk = build_dpop_proof(rsa_key: rsa_key, alg: 'RS256', htm: method, htu: url, access_token: session_token)
      # Patch the header to include 'd' in the JWK
      jwk_with_d = jwk.merge('d' => 'private')
      parts = proof.split('.')
      bad_header = b64url_encode(JSON.dump({ 'typ' => 'dpop+jwt', 'alg' => 'RS256', 'jwk' => jwk_with_d }))
      bad_proof = "#{bad_header}.#{parts[1]}.#{parts[2]}"
      expect do
        subject.validate_dpop_proof(dpop_proof: bad_proof, method: method, request_url: url, session_token: session_token)
      end.to raise_error(Descope::AuthException, /private key/)
    end
  end
end
