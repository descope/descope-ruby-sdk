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
      expect { @instance.send(:validate_and_load_public_key, ['some_key'])}.to raise_error(Descope::AuthException)
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
      allow(@instance).to receive(:token_validation_v2).and_return({ 'keys' => [public_key] })
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
  end
end
