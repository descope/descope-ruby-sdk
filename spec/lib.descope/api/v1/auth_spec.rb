# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Auth do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Auth)
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Mixins::Common::EndpointsV1)
    @instance = dummy_instance
  end

  LEEWAY = 10
  CLOCK = Time.now.to_i
  ALGORITHM = 'RS256'.freeze
  CONTEXT = { algorithm: ALGORITHM, leeway: LEEWAY, audience: 'tokens-test-123',
              issuer: 'https://tokens-test.descope.com/', clock: CLOCK }.freeze

  let(:public_key) do
    {
      'alg' => 'RS256',
      'e' => 'AQAB',
      'kid' => 'SK2ZoKi2Q4I5U8SjammTyOXRWvKl0',
      'kty' => 'RSA',
      'n' => 'shNRO_U_YXlYVNC-dXi49tt5Za3aUVhdC59TqYAlNIaD-nnnQzF__MuEtROzEzWDISXpmAxMcK0zvELikeSVjzjO8KiTrv29sx-Srt8nd9t7wvT8YE93X2U3HOqBXs5a4MXhnaBfzEQPgwnysDGT0HSeqpTLDJ3wvwkvpAOANqAudcgjDbfWAp59WBJWrfM8WSYNAt_NGSrqVJomWIFrwTwmYkn6Fs2bvu6y4TmZJwqfvGklGA6tV3vXwVTWzEYhSybo5CfODu6bHGP9KpXlvNIpf4eJ80i5WjI2GCYx88D3l79p0rEdP2zRr_a45gfJO3dz4DmHVBAlu1M0IIq6DQ',
      'use' => 'sig'
    }
  end

  context 'validate_and_load_public_key' do
    it 'is expected to validate and load public key' do
      expect { @instance.send(:validate_and_load_public_key, ['some_key']) }.to raise_error(Descope::AuthException)
    end

    it 'is expected to fail parsing bad public key JSON' do
      expect do
        @instance.send(:validate_and_load_public_key, '{ this: is not valid JSON')
      end.to raise_error(
        Descope::AuthException, /Unable to parse public key json, error/
      )
    end

    it 'is expected to fail on missing alg property' do
      expect do
        @instance.send(:validate_and_load_public_key, { 'kid' => 'some_kid' })
      end.to raise_error(
        Descope::AuthException, /Unable to load public key. Missing property: alg/
      )
    end

    it 'is expected to fail on missing kid property' do
      expect do
        @instance.send(:validate_and_load_public_key, { 'alg' => 'some_alg' })
      end.to raise_error(
        Descope::AuthException, /Unable to load public key. Missing property: kid/
      )
    end

    it 'is expected to load with correct public key' do
      returned_value = nil

      expect do
        returned_value = @instance.send(:validate_and_load_public_key, public_key)
      end.not_to raise_error

      expected_value = [public_key['kid'], JWT::JWK.new(public_key), public_key['alg']]
      expect(returned_value).to eq(expected_value)
    end
  end

  context 'fetch_public_keys' do
    it 'is expected to fetch public keys' do
      allow(@instance).to receive(:token_validation_key).and_return({ 'keys' => [public_key] })
      expect { @instance.send(:fetch_public_keys) }.not_to raise_error
      expect(@instance.instance_variable_get(:@public_keys)).not_to be_nil
      expect(@instance.instance_variable_get(:@public_keys)).to eq(
        { public_key['kid'] => [JWT::JWK.new(public_key), public_key['alg']] }
      )
    end
  end

  context 'jwt_get_unverified_header' do
    it 'is expected to fail parsing bad token' do
      expect do
        @instance.send(:jwt_get_unverified_header, 'bad_token')
      end.to raise_error(
        Descope::AuthException, /Unable to parse token/
      )
    end

    it 'is expected to return header' do
      header = { 'some_header' => 'some_value' }
      token = JWT.encode({}, nil, 'none', header)
      expect(@instance.send(:jwt_get_unverified_header, token)).to eq(header.merge('alg' => 'none'))
    end
  end

  context 'validate_token' do
    it 'is expected to fail on missing token' do
      expect do
        @instance.send(:validate_token, nil)
      end.to raise_error(Descope::AuthException, /Token validation received empty token/)
      expect do
        @instance.send(:validate_token, '')
      end.to raise_error(Descope::AuthException, /Token validation received empty token/)
    end

    it 'is expected to fail on missing alg property' do
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:jwt_get_unverified_header).and_return({ 'alg' => 'none' })
      expect do
        @instance.send(:validate_token, 'some_token')
      end.to raise_error(Descope::AuthException, /Token header is missing property: alg/)
    end

    it 'is expected to fail on missing kid property' do
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:jwt_get_unverified_header).and_return({ 'alg' => 'RS256' })
      expect do
        @instance.send(:validate_token, 'some_token')
      end.to raise_error(Descope::AuthException, /Token header is missing property: kid/)
    end

    it 'is expected to fail on missing public key after fetch_public_keys is called' do
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:jwt_get_unverified_header).and_return(
        {
          'alg' => 'RS256',
          'kid' => 'some_kid'
        }
      )
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:fetch_public_keys).and_return(nil)
      expect do
        @instance.send(:validate_token, 'some_token')
      end.to raise_error(Descope::AuthException, /Unable to validate public key. Public key not found./)
    end

    it 'is expected to fail when alg_header != alg_from_key' do
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:jwt_get_unverified_header).and_return(
        {
          'alg' => 'RS384',
          'kid' => 'some_kid'
        }
      )
      # bypassing fetch_public_keys since all we need is the set of public_keys attribute on the client class
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:fetch_public_keys).and_return(nil)
      expect(
        @instance.instance_variable_set(
          :@public_keys, { 'some_kid' => [JWT::JWK.new(public_key), public_key['alg']] }
        )
      )

      expect do
        @instance.send(:validate_token, 'some_token')
      end.to raise_error(
        Descope::AuthException,
        /Algorithm signature in JWT header does not match the algorithm signature in the Public key./
      )
    end

    it 'is expected to decode the token successfully' do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:jwt_get_unverified_header).and_return(
        {
          'alg' => 'RS256',
          'kid' => 'some_kid'
        }
      )
      # bypassing fetch_public_keys since all we need is the set of public_keys attribute on the client class
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:fetch_public_keys).and_return(nil)
      expect(
        @instance.instance_variable_set(
          :@public_keys, { 'some_kid' => [JWT::JWK.new(rsa_public), public_key['alg']] }
        )
      )

      payload = { data: 'test' }
      default_payload = { iss: CONTEXT[:issuer], sub: 'user123', aud: CONTEXT[:audience], exp: CLOCK + LEEWAY,
                          iat: CLOCK }
      token = JWT.encode(default_payload.merge(payload), rsa_private, ALGORITHM)

      expect do
        exp_in_seconds = 20
        puts "\nAuthSpec.validate_token::Sleeping for #{exp_in_seconds} seconds to test token expiration. Please wait...\n"
        sleep(exp_in_seconds)
        @instance.send(:validate_token, token)
      end.to raise_error(
        Descope::AuthException, /Signature has expired/
      )

      expect(
        @instance.instance_variable_set(
          :@jwt_validation_leeway, 120
        )
      )
      expect do
        @instance.send(:validate_token, token)
      end.to_not raise_error
    end

    it 'is expected to use @public_keys in a thread safe manner' do
      optional_parameters = { kid: 'some-kid', use: 'sig', alg: ALGORITHM }
      jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), optional_parameters)
      payload = { data: 'data' }
      token = JWT.encode(payload, jwk.signing_key, jwk[:alg], kid: jwk[:kid])

      # JSON Web Key Set for advertising your signing keys
      jwks_hash = JWT::JWK::Set.new(jwk).export
      jwks_hash.transform_keys!(&:to_s)['keys'][0].transform_keys!(&:to_s)

      counter = 0
      # stub the fetch_keys API call to get keys (/v2/keys/{project_id}) with the public key created above
      allow(@instance).to receive(:token_validation_key) do |*args|
        counter += 1
        jwks_hash
      end

      # Create an array to hold threads
      threads = []

      # Make sure public_keys is only empty once

      # Declare errors array with thread safety
      errors = Concurrent::Array.new

      10.times do
        threads << Thread.new do
          begin
            @instance.send(:validate_token, token)
          rescue StandardError => e
            puts "Error: #{e}"
            errors << e
          end
        end
      end

      # Wait for all threads to finish
      threads.each(&:join)

      # Expect no errors
      expect(errors).to have_attributes(length: 0)
      expect(counter).to eq(1)
    end
  end

  context '.select_tenant' do
    it 'is expected to respond to select tenant' do
      expect(@instance).to respond_to(:select_tenant)
    end

    it 'is expected to select tenant' do
      jwt_response = {
        'sessionJwt' => 'fake_session_jwt',
        'refreshJwt' => 'fake_refresh_jwt',
        'cookies' => {
          'refresh_token' => 'fake_refresh_cookie'
        }
      }

      expect(@instance).to receive(:post).with(
        SELECT_TENANT_PATH, { tenantId: 'tenant123' }, {}, 'refresh-token'
      ).and_return(jwt_response)

      allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)

      expect { @instance.select_tenant(tenant_id: 'tenant123', refresh_token: 'refresh-token') }.not_to raise_error
    end
  end

  context '.validate_tenant_permissions' do
    it 'is expected to respond to validate tenant permissions' do
      expect(@instance).to respond_to(:validate_tenant_permissions)
    end

    it 'is expected to respond to validate permissions' do
      expect(@instance).to respond_to(:validate_permissions)
    end

    # rubocop:disable Metrics/LineLength
    it 'is expected to return false when jwt response are empty' do
      expect(@instance.validate_permissions(jwt_response: {}, permissions: ['Perm 1'])).to be false
    end

    it 'is expected to return false when jwt response permissions are empty and the passed permissions are not empty' do
      expect(@instance.validate_permissions(jwt_response: { 'permissions' => [] }, permissions: ['Perm 1'])).to be false
    end

    it 'is expected to return true when jwt response permissions are empty and the passed permissions are empty' do
      expect(@instance.validate_permissions(jwt_response: { 'permissions' => [] }, permissions: [])).to be true
    end

    it 'is expected to return true when jwt response permissions and the passed permissions match' do
      expect(@instance.validate_permissions(jwt_response: { 'permissions' => ['Perm 1'] }, permissions: 'Perm 1')).to be true
      expect(@instance.validate_permissions(jwt_response: { 'permissions' => ['Perm 1'] }, permissions: ['Perm 1'])).to be true
    end

    it 'is expected to return false when jwt response permissions and the passed permissions do not match' do
      expect(@instance.validate_permissions(jwt_response: { 'permissions' => ['Perm 1'] }, permissions: ['Perm 2'])).to be false
    end

    #   # Tenant level
    it 'is expected to return false when jwt response tenants are empty and the passed permissions are not empty' do
      expect(@instance.validate_tenant_permissions(jwt_response: { 'tenants' => {} }, tenant: 't1', permissions: ['Perm 2'])).to be false
    end

    it 'is expected to return false when jwt response tenants has a tenant with empty or no permissions field and the passed permissions are not empty' do
      expect(@instance.validate_tenant_permissions(jwt_response: { 'tenants' => { 't1' => {} } }, tenant: 't1', permissions: ['Perm 2'])).to be false
    end

    it 'is expected to return true when jwt response tenants has a tenant with permissions field and the passed permissions are empty' do
      expect(@instance.validate_tenant_permissions(jwt_response: { 'tenants' => { 't1' => { 'permissions' => 'Perm 1' } } }, tenant: 't1', permissions: [])).to be true
    end

    it 'is expected to return true when jwt response tenants has a tenant with permissions field ad string and the passed permissions is an array' do
      expect(@instance.validate_tenant_permissions(jwt_response: { 'tenants' => { 't1' => { 'permissions' => 'Perm 1' } } }, tenant: 't1', permissions: ['Perm 1'])).to be true
    end

    it 'is expected to return false when jwt response tenants has a tenant with permissions field and the passed permissions do not match' do
      expect(@instance.validate_tenant_permissions(jwt_response: { 'tenants' => { 't1' => { 'permissions' => 'Perm 1' } } }, tenant: 't1', permissions: ['Perm 2'])).to be false
      expect(@instance.validate_tenant_permissions(jwt_response: { 'tenants' => { 't1' => { 'permissions' => 'Perm 1' } } }, tenant: 't1', permissions: ['Perm 1', 'Perm 2'])).to be false
    end

    it 'is expected to return false when jwt response tenants and passed tenant do not match' do
      expect(@instance.validate_tenant_permissions(jwt_response: { 'tenants' => { 't1' => { 'permissions' => 'Perm 1' } } }, tenant: 't2', permissions: [])).to be false
    end
  end

  context '.validate_roles' do
    it 'is expected to respond to validate roles' do
      expect(@instance).to respond_to(:validate_roles)
    end

    it 'is expected to return false when jwt response are empty' do
      expect(@instance.validate_roles(jwt_response: {}, roles: ['Role 1'])).to be false
    end

    it 'is expected to return false when jwt response roles are empty and the passed roles are not empty' do
      expect(@instance.validate_roles(jwt_response: { 'roles' => [] }, roles: ['Role 1'])).to be false
    end

    it 'is expected to return true when jwt response roles are empty and the passed roles are empty' do
      expect(@instance.validate_roles(jwt_response: { 'roles' => [] }, roles: [])).to be true
    end

    it 'is expected to return true when jwt response roles and the passed roles match' do
      expect(@instance.validate_roles(jwt_response: { 'roles' => ['Role 1'] }, roles: 'Role 1')).to be true
      expect(@instance.validate_roles(jwt_response: { 'roles' => ['Role 1'] }, roles: ['Role 1'])).to be true
    end

    it 'is expected to return false when jwt response roles and the passed roles do not match' do
      expect(@instance.validate_roles(jwt_response: { 'roles' => ['Role 1'] }, roles: ['Role 2'])).to be false
    end

    # Tenant level
    it 'is expected to return false when jwt response tenants are empty and the passed roles are not empty' do
      expect(@instance.validate_tenant_roles(jwt_response: { 'tenants' => {} }, tenant: 't1', roles: ['Role 2'])).to be false
    end

    it 'is expected to return false when jwt response tenants has a tenant with empty or no roles field and the passed roles are not empty' do
      expect(@instance.validate_tenant_roles(jwt_response: { 'tenants' => { 't1' => {} } }, tenant: 't1', roles: ['Role 2'])).to be false
    end

    it 'is expected to return true when jwt response tenants has a tenant with roles field and the passed roles are empty' do
      expect(@instance.validate_tenant_roles(jwt_response: { 'tenants' => { 't1' => { 'roles' => 'Role 1' } } }, tenant: 't1', roles: [])).to be true
    end

    it 'is expected to return true when jwt response tenants has a tenant with roles field ad string and the passed roles is an array' do
      expect(@instance.validate_tenant_roles(jwt_response: { 'tenants' => { 't1' => { 'roles' => 'Role 1' } } }, tenant: 't1', roles: ['Role 1'])).to be true
    end

    it 'is expected to return false when jwt response tenants has a tenant with roles field and the passed roles do not match' do
      expect(@instance.validate_tenant_roles(jwt_response: { 'tenants' => { 't1' => { 'roles' => 'Role 1' } } }, tenant: 't1', roles: ['Role 2'])).to be false
      expect(@instance.validate_tenant_roles(jwt_response: { 'tenants' => { 't1' => { 'roles' => 'Role 1' } } }, tenant: 't1', roles: ['Role 1', 'Role 2'])).to be false
    end

    it 'is expected to return false when jwt response tenants and passed tenant do not match' do
      expect(@instance.validate_tenant_roles(jwt_response: { 'tenants' => { 't1' => { 'roles' => 'Role 1' } } }, tenant: 't2', roles: [])).to be false
    end
  end

  context '.exchange_access_key' do
    it 'is expected to respond to exchange access key' do
      expect(@instance).to respond_to(:exchange_access_key)
    end

    it 'is expected to fail when access key is nil' do
      expect { @instance.exchange_access_key(access_key: nil) }.to raise_error(Descope::AuthException)
    end

    it 'is expected to fail when access key is empty' do
      expect { @instance.exchange_access_key(access_key: '') }.to raise_error(Descope::AuthException)
    end

    it 'is expected to fail when access key is not a string' do
      expect { @instance.exchange_access_key(access_key: 123) }.to raise_error(Descope::AuthException)
    end

    it 'is expected to successfully exchange access key without login_options' do
      jwt_response = {
        'sessionJwt' => 'fake_session_jwt',
        'refreshJwt' => 'fake_refresh_jwt'
      }
      access_key = 'abc'

      expect(@instance).to receive(:post).with(
        EXCHANGE_AUTH_ACCESS_KEY_PATH, { loginOptions: {}, audience: 'IT' }, {}, access_key
      ).and_return(jwt_response)

      allow(@instance).to receive(:generate_auth_info).and_return(jwt_response)

      expect { @instance.exchange_access_key(access_key:, audience: 'IT') }.not_to raise_error
    end

    it 'is expected to successfully exchange access key with login_options' do
      jwt_response = {
        'sessionJwt' => 'fake_session_jwt',
        'refreshJwt' => 'fake_refresh_jwt'
      }
      access_key = 'abc'

      expect(@instance).to receive(:post).with(
        EXCHANGE_AUTH_ACCESS_KEY_PATH,
        { loginOptions: { customClaims: { k1: 'v1' } }, audience: 'IT' },
        {},
        access_key
      ).and_return(jwt_response)

      allow(@instance).to receive(:generate_auth_info).and_return(jwt_response)

      expect { @instance.exchange_access_key(access_key:, login_options: { customClaims: { k1: 'v1' } }, audience: 'IT') }.not_to raise_error
    end
  end

  describe '#generate_auth_info cookie handling enhancements' do
    let(:audience) { nil }
    let(:session_jwt) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbSJ9.session_sig' }
    let(:refresh_jwt) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbSJ9.refresh_sig' }
    
    let(:mock_token_validation) do
      {
        'iss' => 'https://api.descope.com/P2abcde12345',
        'sub' => 'U2abcde12345',
        'permissions' => ['read', 'write'],
        'roles' => ['admin'],
        'tenants' => { 'tenant1' => { 'permissions' => ['read'] } }
      }
    end

    before do
      allow(@instance).to receive(:validate_token).and_return(mock_token_validation)
    end

    context 'when session token is in cookies (custom domain scenario)' do
      let(:response_body) do
        {
          'userId' => 'test123',
          'cookieExpiration' => 1640704758,
          'cookieDomain' => 'dev.rextherapymanager.com',
          'cookies' => {
            'DS' => session_jwt,      # Session token in cookies
            'DSR' => refresh_jwt      # Refresh token in cookies
          }
        }
      end

      it 'extracts session token from cookies when not in response body' do
        result = @instance.send(:generate_auth_info, response_body, nil, true, audience)
        
        expect(result['sessionToken']).to eq(mock_token_validation)
        expect(result['refreshSessionToken']).to eq(mock_token_validation)
      end

      it 'validates session token from cookies' do
        expect(@instance).to receive(:validate_token).with(session_jwt, audience).and_return(mock_token_validation)
        expect(@instance).to receive(:validate_token).with(refresh_jwt, audience).and_return(mock_token_validation)
        
        @instance.send(:generate_auth_info, response_body, nil, true, audience)
      end

      it 'includes permissions and roles from cookie tokens' do
        result = @instance.send(:generate_auth_info, response_body, nil, true, audience)
        
        expect(result['permissions']).to eq(['read', 'write'])
        expect(result['roles']).to eq(['admin'])
        expect(result['tenants']).to eq({ 'tenant1' => { 'permissions' => ['read'] } })
      end
    end

    context 'when session token is in response body and refresh token in cookies' do
      let(:response_body) do
        {
          'sessionJwt' => session_jwt,  # Session token in response body
          'userId' => 'test123',
          'cookies' => {
            'DSR' => refresh_jwt        # Only refresh token in cookies
          }
        }
      end

      it 'uses session token from response body and refresh token from cookies' do
        expect(@instance).to receive(:validate_token).with(session_jwt, audience).and_return(mock_token_validation)
        expect(@instance).to receive(:validate_token).with(refresh_jwt, audience).and_return(mock_token_validation)
        
        result = @instance.send(:generate_auth_info, response_body, nil, true, audience)
        
        expect(result['sessionToken']).to eq(mock_token_validation)
        expect(result['refreshSessionToken']).to eq(mock_token_validation)
      end
    end

    context 'when refresh token is passed as parameter' do
      let(:response_body) do
        {
          'userId' => 'test123',
          'cookies' => {
            'DS' => session_jwt         # Only session token in cookies
          }
        }
      end

      it 'uses passed refresh token when not in response body or cookies' do
        expect(@instance).to receive(:validate_token).with(session_jwt, audience).and_return(mock_token_validation)
        expect(@instance).to receive(:validate_token).with(refresh_jwt, audience).and_return(mock_token_validation)
        
        result = @instance.send(:generate_auth_info, response_body, refresh_jwt, true, audience)
        
        expect(result['sessionToken']).to eq(mock_token_validation)
        expect(result['refreshSessionToken']).to eq(mock_token_validation)
      end
    end

    context 'error handling for missing tokens' do
      let(:response_body) do
        {
          'userId' => 'test123',
          'cookieExpiration' => 1640704758,
          'cookies' => {}  # No tokens anywhere
        }
      end

      it 'raises helpful error when no refresh token is found' do
        expect {
          @instance.send(:generate_auth_info, response_body, nil, true, audience)
        }.to raise_error(Descope::AuthException, /Could not find refreshJwt in response body \/ cookies \/ passed in refresh_token/)
      end
    end

    context 'backward compatibility' do
      let(:traditional_response_body) do
        {
          'sessionJwt' => session_jwt,
          'refreshJwt' => refresh_jwt,
          'userId' => 'test123'
        }
      end

      it 'continues to work with traditional response body tokens' do
        expect(@instance).to receive(:validate_token).with(session_jwt, audience).and_return(mock_token_validation)
        expect(@instance).to receive(:validate_token).with(refresh_jwt, audience).and_return(mock_token_validation)
        
        result = @instance.send(:generate_auth_info, traditional_response_body, nil, true, audience)
        
        expect(result['sessionToken']).to eq(mock_token_validation)
        expect(result['refreshSessionToken']).to eq(mock_token_validation)
      end

      it 'works with same-domain cookies (existing RestClient behavior)' do
        response_with_restclient_cookies = {
          'userId' => 'test123',
          'cookies' => {
            'DSR' => refresh_jwt
          }
        }

        expect(@instance).to receive(:validate_token).with(refresh_jwt, audience).and_return(mock_token_validation)
        
        result = @instance.send(:generate_auth_info, response_with_restclient_cookies, nil, false, audience)
        
        expect(result['refreshSessionToken']).to eq(mock_token_validation)
      end
    end
  end
end
