# frozen_string_literal: true

require 'spec_helper'

describe 'Cookie Domain Fix Integration' do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth)
    dummy_instance.extend(Descope::Mixins::HTTP)
    dummy_instance.extend(Descope::Mixins::Common::EndpointsV1)
    @instance = dummy_instance
  end

  describe 'refresh_session with custom domain cookies' do
    let(:refresh_token) { 'test_refresh_token' }
    let(:audience) { nil }
    
    let(:session_jwt) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbS9QMmFiY2RlMTIzNDUiLCJzdWIiOiJVMmFiY2RlMTIzNDUifQ.session_signature' }
    let(:refresh_jwt) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbS9QMmFiY2RlMTIzNDUiLCJzdWIiOiJVMmFiY2RlMTIzNDUifQ.refresh_signature' }

    context 'when Descope is configured for cookie-only tokens with custom domain' do
      let(:api_response_body) do
        # Response body without sessionJwt/refreshJwt (cookie-only configuration)
        {
          'userId' => 'test123',
          'cookieExpiration' => 1640704758,
          'cookieDomain' => 'dev.rextherapymanager.com',
          'cookiePath' => '/'
        }
      end

      let(:set_cookie_headers) do
        [
          "DS=#{session_jwt}; Path=/; Domain=dev.rextherapymanager.com; HttpOnly; Secure; SameSite=None",
          "DSR=#{refresh_jwt}; Path=/; Domain=dev.rextherapymanager.com; HttpOnly; Secure; SameSite=None; Max-Age=2592000"
        ]
      end

      let(:mock_response) do
        double('response').tap do |response|
          allow(response).to receive(:code).and_return(200)
          allow(response).to receive(:body).and_return(api_response_body.to_json)
          allow(response).to receive(:cookies).and_return({}) # RestClient filters out custom domain cookies
          allow(response).to receive(:headers).and_return({ 'set-cookie' => set_cookie_headers })
        end
      end

      before do
        allow(@instance).to receive(:validate_refresh_token_not_nil).and_return(true)
        allow(@instance).to receive(:validate_token).and_return({
          'iss' => 'https://api.descope.com/P2abcde12345',
          'sub' => 'U2abcde12345',
          'permissions' => [],
          'roles' => [],
          'tenants' => {}
        })
        allow(@instance).to receive(:call).and_return(mock_response)
      end

      it 'successfully extracts tokens from Set-Cookie headers' do
        result = @instance.refresh_session(refresh_token: refresh_token, audience: audience)
        
        expect(result).to be_a(Hash)
        expect(result['sessionToken']).to be_present
        expect(result['refreshSessionToken']).to be_present
        expect(result['user']).to be_present
      end

      it 'validates the extracted session token' do
        expect(@instance).to receive(:validate_token).with(session_jwt, audience).and_return({
          'iss' => 'https://api.descope.com/P2abcde12345',
          'sub' => 'U2abcde12345'
        })

        @instance.refresh_session(refresh_token: refresh_token, audience: audience)
      end

      it 'validates the extracted refresh token' do
        expect(@instance).to receive(:validate_token).with(refresh_jwt, audience).and_return({
          'iss' => 'https://api.descope.com/P2abcde12345',
          'sub' => 'U2abcde12345'
        })

        @instance.refresh_session(refresh_token: refresh_token, audience: audience)
      end

      it 'includes cookie metadata in response' do
        result = @instance.refresh_session(refresh_token: refresh_token, audience: audience)
        
        expect(result['cookieData']).to be_present
        expect(result['cookieData']['domain']).to eq('dev.rextherapymanager.com')
        expect(result['cookieData']['path']).to eq('/')
      end
    end

    context 'when only refresh token is in cookies (partial custom domain)' do
      let(:api_response_body) do
        {
          'sessionJwt' => session_jwt,  # Session token in response body
          'userId' => 'test123',
          'cookieExpiration' => 1640704758,
          'cookieDomain' => 'dev.rextherapymanager.com'
        }
      end

      let(:set_cookie_headers) do
        [
          "DSR=#{refresh_jwt}; Path=/; Domain=dev.rextherapymanager.com; HttpOnly; Secure; Max-Age=2592000"
        ]
      end

      let(:mock_response) do
        double('response').tap do |response|
          allow(response).to receive(:code).and_return(200)
          allow(response).to receive(:body).and_return(api_response_body.to_json)
          allow(response).to receive(:cookies).and_return({})
          allow(response).to receive(:headers).and_return({ 'set-cookie' => set_cookie_headers })
        end
      end

      before do
        allow(@instance).to receive(:validate_refresh_token_not_nil).and_return(true)
        allow(@instance).to receive(:validate_token).and_return({
          'iss' => 'https://api.descope.com/P2abcde12345',
          'sub' => 'U2abcde12345',
          'permissions' => [],
          'roles' => [],
          'tenants' => {}
        })
        allow(@instance).to receive(:call).and_return(mock_response)
      end

      it 'handles mixed token sources (response body + custom domain cookies)' do
        result = @instance.refresh_session(refresh_token: refresh_token, audience: audience)
        
        expect(result).to be_a(Hash)
        expect(result['sessionToken']).to be_present
        expect(result['refreshSessionToken']).to be_present
      end
    end

    context 'error handling for custom domain configurations' do
      let(:api_response_body) do
        {
          'userId' => 'test123',
          'cookieExpiration' => 1640704758,
          'cookieDomain' => 'dev.rextherapymanager.com'
        }
      end

      let(:mock_response_no_cookies) do
        double('response').tap do |response|
          allow(response).to receive(:code).and_return(200)
          allow(response).to receive(:body).and_return(api_response_body.to_json)
          allow(response).to receive(:cookies).and_return({})
          allow(response).to receive(:headers).and_return({}) # No Set-Cookie headers
        end
      end

      before do
        allow(@instance).to receive(:validate_refresh_token_not_nil).and_return(true)
        allow(@instance).to receive(:validate_token).and_return({
          'iss' => 'https://api.descope.com/P2abcde12345',
          'sub' => 'U2abcde12345'
        })
        allow(@instance).to receive(:call).and_return(mock_response_no_cookies)
      end

      it 'provides helpful error message when no tokens are found' do
        expect {
          @instance.refresh_session(refresh_token: refresh_token, audience: audience)
        }.to raise_error(Descope::AuthException, /Could not find refresh token.*custom cookie domains/)
      end
    end
  end

  describe 'validate_and_refresh_session with custom domain cookies' do
    let(:session_token) { 'expired_session_token' }
    let(:refresh_token) { 'valid_refresh_token' }
    let(:audience) { nil }

    context 'when session is expired and refresh uses custom domain cookies' do
      let(:refresh_jwt) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbSJ9.signature' }
      
      let(:api_response_body) do
        {
          'userId' => 'test123',
          'cookieExpiration' => 1640704758,
          'cookieDomain' => 'dev.rextherapymanager.com'
        }
      end

      let(:set_cookie_headers) do
        [
          "DS=new_session_jwt; Path=/; Domain=dev.rextherapymanager.com; HttpOnly; Secure",
          "DSR=#{refresh_jwt}; Path=/; Domain=dev.rextherapymanager.com; HttpOnly; Secure; Max-Age=2592000"
        ]
      end

      let(:mock_response) do
        double('response').tap do |response|
          allow(response).to receive(:code).and_return(200)
          allow(response).to receive(:body).and_return(api_response_body.to_json)
          allow(response).to receive(:cookies).and_return({})
          allow(response).to receive(:headers).and_return({ 'set-cookie' => set_cookie_headers })
        end
      end

      before do
        # Mock session validation to fail (expired token)
        allow(@instance).to receive(:validate_session).and_raise(Descope::AuthException.new('Token expired'))
        
        # Mock refresh_session to work with custom domain cookies
        allow(@instance).to receive(:validate_refresh_token_not_nil).and_return(true)
        allow(@instance).to receive(:validate_token).and_return({
          'iss' => 'https://api.descope.com/P2abcde12345',
          'sub' => 'U2abcde12345',
          'permissions' => [],
          'roles' => [],
          'tenants' => {}
        })
        allow(@instance).to receive(:call).and_return(mock_response)
      end

      it 'falls back to refresh_session when validate_session fails' do
        expect(@instance).to receive(:refresh_session).with(
          refresh_token: refresh_token,
          audience: audience
        ).and_call_original

        result = @instance.validate_and_refresh_session(
          session_token: session_token,
          refresh_token: refresh_token,
          audience: audience
        )

        expect(result).to be_a(Hash)
      end
    end
  end
end