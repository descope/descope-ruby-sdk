# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'digest'
require 'json'
require 'uri'

module Descope
  # DPoP (Demonstrated Proof of Possession) support per RFC 9449.
  # Validates DPoP proof JWTs when session tokens are sender-constrained.
  module DPoP
    DPOP_ALLOWED_ALGS = %w[RS256 RS384 RS512 ES256 ES384 ES512 PS256 PS384 PS512 EdDSA].freeze
    DPOP_MAX_PROOF_LEN = 8192
    DPOP_IAT_BACKWARD_WINDOW = 60 # seconds
    DPOP_IAT_FORWARD_WINDOW = 5  # seconds

    EC_CURVE_MAP = {
      'P-256' => 'prime256v1',
      'P-384' => 'secp384r1',
      'P-521' => 'secp521r1'
    }.freeze

    DIGEST_FOR_ALG = {
      'RS256' => 'SHA256', 'RS384' => 'SHA384', 'RS512' => 'SHA512',
      'PS256' => 'SHA256', 'PS384' => 'SHA384', 'PS512' => 'SHA512',
      'ES256' => 'SHA256', 'ES384' => 'SHA384', 'ES512' => 'SHA512'
    }.freeze

    # Validates a DPoP proof JWT per RFC 9449 §7.
    #
    # If the session_token has no cnf.jkt claim, validation is skipped (token is not DPoP-bound).
    # Raises Descope::AuthException if proof is invalid.
    #
    # NOTE — jti replay protection (RFC 9449 §11.1): this SDK is stateless and has no
    # server-side storage, so jti uniqueness enforcement is out of scope. Callers that
    # require replay protection must implement their own jti cache. This matches the
    # go-sdk reference implementation (descope/go-sdk#737).
    #
    # @param dpop_proof [String] the value of the DPoP HTTP header
    # @param method [String] the HTTP method of the request (e.g. "GET", "POST")
    # @param request_url [String] the full URL of the request
    # @param session_token [String] the access token (JWT) being used
    def validate_dpop_proof(dpop_proof:, method:, request_url:, session_token:)
      # Decode access token claims to check for cnf.jkt (without full verification)
      claims = extract_token_claims(session_token)
      stored_jkt = get_dpop_thumbprint(claims)

      # If no cnf.jkt, token is not DPoP-bound — skip validation
      return if stored_jkt.nil? || stored_jkt.empty?

      dpop_proof = dpop_proof.to_s.strip

      raise Descope::AuthException.new('DPoP proof is empty', code: 400) if dpop_proof.empty?
      raise Descope::AuthException.new('DPoP proof exceeds maximum length', code: 400) if dpop_proof.length > DPOP_MAX_PROOF_LEN

      parts = dpop_proof.split('.')
      raise Descope::AuthException.new('DPoP proof is not a valid JWT (must have 3 parts)', code: 400) unless parts.length == 3

      # Parse header
      header = begin
        JSON.parse(Base64.urlsafe_decode64(pad_base64(parts[0])))
      rescue StandardError
        raise Descope::AuthException.new('DPoP proof header is not valid JSON', code: 400)
      end

      unless header['typ'] == 'dpop+jwt'
        raise Descope::AuthException.new("DPoP proof header typ must be 'dpop+jwt', got '#{header['typ']}'", code: 400)
      end

      alg = header['alg']
      unless DPOP_ALLOWED_ALGS.include?(alg)
        raise Descope::AuthException.new("DPoP proof uses unsupported algorithm '#{alg}'", code: 400)
      end

      jwk_dict = header['jwk']
      unless jwk_dict.is_a?(Hash)
        raise Descope::AuthException.new('DPoP proof header must contain a jwk', code: 400)
      end

      if jwk_dict['kty'] == 'oct'
        raise Descope::AuthException.new('DPoP proof JWK must not be a symmetric key (kty=oct)', code: 400)
      end

      kty = jwk_dict['kty']
      private_key_present =
        case kty
        when 'RSA'
          %w[d p q dp dq qi].any? { |param| jwk_dict.key?(param) }
        when 'EC', 'OKP'
          jwk_dict.key?('d')
        else
          jwk_dict.key?('d')
        end
      if private_key_present
        raise Descope::AuthException.new('DPoP proof JWK must not contain a private key', code: 400)
      end

      # Import public key and verify signature
      public_key = import_jwk_public_key(jwk_dict, alg)

      signing_input = "#{parts[0]}.#{parts[1]}"
      begin
        signature_bytes = Base64.urlsafe_decode64(pad_base64(parts[2]))
      rescue StandardError
        raise Descope::AuthException.new('DPoP proof signature is not valid base64url', code: 400)
      end

      unless verify_dpop_signature(public_key, signing_input, signature_bytes, alg)
        raise Descope::AuthException.new('DPoP proof signature verification failed', code: 401)
      end

      # Parse payload
      payload = begin
        JSON.parse(Base64.urlsafe_decode64(pad_base64(parts[1])))
      rescue StandardError
        raise Descope::AuthException.new('DPoP proof payload is not valid JSON', code: 400)
      end

      validate_dpop_payload_claims(payload, method, request_url)
      validate_dpop_ath(payload, session_token)
      validate_dpop_jkt(jwk_dict, stored_jkt)
    end

    private

    # Extracts cnf.jkt from parsed JWT claims hash.
    # Returns nil if not present.
    def get_dpop_thumbprint(claims)
      return nil unless claims.is_a?(Hash)

      cnf = claims['cnf']
      return nil unless cnf.is_a?(Hash)

      cnf['jkt']
    end

    # Extract JWT claims without signature verification (used to check cnf.jkt)
    def extract_token_claims(session_token)
      return {} if session_token.nil? || session_token.empty?

      parts = session_token.split('.')
      return {} unless parts.length == 3

      begin
        JSON.parse(Base64.urlsafe_decode64(pad_base64(parts[1])))
      rescue StandardError
        {}
      end
    end

    def validate_dpop_payload_claims(payload, method, request_url)
      jti = payload['jti']
      unless jti.is_a?(String) && !jti.empty?
        raise Descope::AuthException.new('DPoP proof payload missing or empty jti', code: 400)
      end

      htm = payload['htm']
      unless htm.is_a?(String) && !htm.empty?
        raise Descope::AuthException.new('DPoP proof payload missing or empty htm', code: 400)
      end

      htu = payload['htu']
      unless htu.is_a?(String) && !htu.empty?
        raise Descope::AuthException.new('DPoP proof payload missing or empty htu', code: 400)
      end

      unless htm.upcase == method.to_s.upcase
        raise Descope::AuthException.new("DPoP proof htm '#{htm}' does not match request method '#{method}'", code: 401)
      end

      unless htu_matches?(htu, request_url)
        raise Descope::AuthException.new("DPoP proof htu '#{htu}' does not match request URL '#{request_url}'", code: 401)
      end

      iat = payload['iat']
      raise Descope::AuthException.new('DPoP proof payload missing iat', code: 400) unless iat.is_a?(Numeric)

      diff = Time.now.to_f - iat.to_f
      if diff <= -DPOP_IAT_FORWARD_WINDOW
        raise Descope::AuthException.new('DPoP proof iat is too far in the future', code: 401)
      end

      if diff >= DPOP_IAT_BACKWARD_WINDOW
        raise Descope::AuthException.new('DPoP proof has expired (iat too old)', code: 401)
      end
    end

    def validate_dpop_ath(payload, session_token)
      ath = payload['ath']
      unless ath.is_a?(String) && !ath.empty?
        raise Descope::AuthException.new('DPoP proof payload missing or empty ath', code: 400)
      end

      expected_ath = Base64.urlsafe_encode64(Digest::SHA256.digest(session_token), padding: false)
      unless ath == expected_ath
        raise Descope::AuthException.new('DPoP proof ath does not match access token hash', code: 401)
      end
    end

    def validate_dpop_jkt(jwk_dict, stored_jkt)
      thumbprint = compute_jwk_thumbprint(jwk_dict)
      unless thumbprint == stored_jkt
        raise Descope::AuthException.new('DPoP proof JWK thumbprint does not match cnf.jkt in access token', code: 401)
      end
    end

    # Computes the JWK thumbprint per RFC 7638.
    # Only required members in alphabetical order, SHA256, base64url no padding.
    def compute_jwk_thumbprint(jwk)
      kty = jwk['kty']
      canonical = case kty
                  when 'EC'
                    { 'crv' => jwk['crv'], 'kty' => kty, 'x' => jwk['x'], 'y' => jwk['y'] }
                  when 'RSA'
                    { 'e' => jwk['e'], 'kty' => kty, 'n' => jwk['n'] }
                  when 'OKP'
                    { 'crv' => jwk['crv'], 'kty' => kty, 'x' => jwk['x'] }
                  else
                    raise Descope::AuthException.new("Unsupported JWK key type for thumbprint: #{kty}", code: 400)
                  end

      # Keys must be sorted alphabetically per RFC 7638
      sorted_json = canonical.sort.to_h.to_json
      Base64.urlsafe_encode64(Digest::SHA256.digest(sorted_json), padding: false)
    end

    # Imports a public key from a JWK dict, cross-checking alg against kty.
    def import_jwk_public_key(jwk, alg)
      kty = jwk['kty']

      # Validate alg/kty compatibility
      if alg.start_with?('RS', 'PS') && kty != 'RSA'
        raise Descope::AuthException.new("alg/kty mismatch: alg '#{alg}' requires kty=RSA but got '#{kty}'", code: 400)
      elsif alg.start_with?('ES') && kty != 'EC'
        raise Descope::AuthException.new("alg/kty mismatch: alg '#{alg}' requires kty=EC but got '#{kty}'", code: 400)
      elsif alg == 'EdDSA' && kty != 'OKP'
        raise Descope::AuthException.new("alg/kty mismatch: alg 'EdDSA' requires kty=OKP but got '#{kty}'", code: 400)
      end

      case kty
      when 'EC'
        import_ec_public_key(jwk)
      when 'RSA'
        import_rsa_public_key(jwk)
      when 'OKP'
        import_okp_public_key(jwk)
      else
        raise Descope::AuthException.new("Unsupported JWK key type: #{kty}", code: 400)
      end
    rescue Descope::AuthException
      raise
    rescue StandardError => e
      raise Descope::AuthException.new("Failed to import JWK public key: #{e.message}", code: 400)
    end

    # Expected byte lengths for EC coordinate values per curve
    EC_COORD_BYTES = {
      'P-256' => 32,
      'P-384' => 48,
      'P-521' => 66
    }.freeze

    def import_ec_public_key(jwk)
      crv = jwk['crv']
      curve_name = EC_CURVE_MAP[crv]
      raise Descope::AuthException.new("Unsupported EC curve: #{crv}", code: 400) if curve_name.nil?

      group = OpenSSL::PKey::EC::Group.new(curve_name)
      x_bytes = Base64.urlsafe_decode64(pad_base64(jwk['x']))
      y_bytes = Base64.urlsafe_decode64(pad_base64(jwk['y']))

      # Validate coordinate lengths per curve (RFC 7518 §6.2.1.2)
      expected_len = EC_COORD_BYTES[crv]
      if x_bytes.bytesize != expected_len
        raise Descope::AuthException.new(
          "EC JWK x coordinate has wrong length for #{crv}: expected #{expected_len} bytes, got #{x_bytes.bytesize}", code: 400
        )
      end
      if y_bytes.bytesize != expected_len
        raise Descope::AuthException.new(
          "EC JWK y coordinate has wrong length for #{crv}: expected #{expected_len} bytes, got #{y_bytes.bytesize}", code: 400
        )
      end

      # Uncompressed point: 0x04 || x || y
      point_octets = "\x04".b + x_bytes.b + y_bytes.b
      point = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(point_octets, 2))
      ec = OpenSSL::PKey::EC.new(group)
      ec.public_key = point
      ec
    end

    def import_rsa_public_key(jwk)
      n = OpenSSL::BN.new(Base64.urlsafe_decode64(pad_base64(jwk['n'])), 2)
      e = OpenSSL::BN.new(Base64.urlsafe_decode64(pad_base64(jwk['e'])), 2)
      rsa = OpenSSL::PKey::RSA.new
      rsa.set_key(n, e, nil)
      rsa
    end

    def import_okp_public_key(jwk)
      # Ed25519 / Ed448 — OKP keys
      crv = jwk['crv']
      unless crv == 'Ed25519'
        raise Descope::AuthException.new("Unsupported OKP curve: #{crv} (only Ed25519 is supported)", code: 400)
      end

      # Ruby OpenSSL supports Ed25519 as a raw key via DER encoding
      x_bytes = Base64.urlsafe_decode64(pad_base64(jwk['x']))
      # SubjectPublicKeyInfo DER for Ed25519:
      # SEQUENCE { SEQUENCE { OID 1.3.101.112 }, BIT STRING { 0x00 || key_bytes } }
      oid_der = "\x30\x05\x06\x03\x2b\x65\x70"  # OID 1.3.101.112 (id-Ed25519)
      bit_string_der = "\x03" + [x_bytes.length + 1].pack('C') + "\x00" + x_bytes
      spki_der = "\x30" + [oid_der.length + bit_string_der.length].pack('C') + oid_der + bit_string_der
      OpenSSL::PKey.read(spki_der)
    rescue Descope::AuthException
      raise
    rescue StandardError
      raise Descope::AuthException.new('EdDSA key import is not supported by this OpenSSL version', code: 400)
    end

    # Verifies DPoP signature. EC sigs in JWT are raw R||S, must convert to DER first.
    def verify_dpop_signature(key, signing_input, signature_bytes, alg)
      digest_name = DIGEST_FOR_ALG[alg]

      if alg.start_with?('ES')
        verify_ec_dpop_signature(key, signing_input, signature_bytes, digest_name)
      elsif alg.start_with?('PS')
        key.verify_pss(digest_name, signature_bytes, signing_input, salt_length: :auto, mgf1_hash: digest_name)
      elsif alg == 'EdDSA'
        key.verify(nil, signature_bytes, signing_input)
      else
        # RS*
        key.verify(OpenSSL::Digest.new(digest_name), signature_bytes, signing_input)
      end
    rescue OpenSSL::PKey::PKeyError, OpenSSL::PKey::RSAError, OpenSSL::PKey::ECError
      false
    end

    def verify_ec_dpop_signature(key, signing_input, signature_bytes, digest_name)
      # JWT EC signatures are raw R||S bytes (each half-length)
      half = signature_bytes.length / 2
      r = OpenSSL::BN.new(signature_bytes[0, half], 2)
      s = OpenSSL::BN.new(signature_bytes[half..], 2)
      der_sig = OpenSSL::ASN1::Sequence([
        OpenSSL::ASN1::Integer(r),
        OpenSSL::ASN1::Integer(s)
      ]).to_der
      key.verify(OpenSSL::Digest.new(digest_name), der_sig, signing_input)
    rescue OpenSSL::PKey::ECError
      false
    end

    # Normalizes and compares htu (from DPoP proof) against the request URL per RFC 9449.
    def htu_matches?(htu, request_url)
      proof_uri = URI.parse(htu)
      request_uri = URI.parse(request_url)

      return false unless proof_uri.scheme && proof_uri.host
      return false unless request_uri.scheme && request_uri.host

      normalize_uri(proof_uri) == normalize_uri(request_uri)
    rescue URI::InvalidURIError
      false
    end

    # Strips query, fragment, normalizes scheme/host to downcase, removes default ports.
    # Per RFC 3986 §6.2.3, an empty path with a present authority is equivalent to "/".
    def normalize_uri(uri)
      scheme = uri.scheme.downcase
      host = uri.host.downcase
      port = uri.port
      # Normalize empty path to "/" per RFC 3986 §6.2.3 (scheme-based normalization)
      path = uri.path.empty? ? '/' : uri.path

      # Strip default ports
      port = nil if (scheme == 'https' && port == 443) || (scheme == 'http' && port == 80)

      "#{scheme}://#{host}#{port ? ":#{port}" : ''}#{path}"
    end

    # Pads a base64url string to a multiple of 4 characters.
    def pad_base64(str)
      str + '=' * ((4 - str.length % 4) % 4)
    end
  end
end
