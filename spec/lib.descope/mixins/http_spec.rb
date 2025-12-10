# frozen_string_literal: true

require 'spec_helper'

describe Descope::Mixins::HTTP do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Mixins::HTTP)
    @instance = dummy_instance
  end

  describe '#parse_cookie_value' do
    it 'extracts cookie value from Set-Cookie header' do
      cookie_header = 'DS=jwt_token_value; Path=/; Domain=example.com; HttpOnly; Secure'
      result = @instance.parse_cookie_value(cookie_header, 'DS')
      expect(result).to eq('jwt_token_value')
    end

    it 'extracts cookie value with complex JWT token' do
      jwt_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbS9QMmFiY2RlMTIzNDUifQ.signature'
      cookie_header = "DSR=#{jwt_token}; Path=/; Domain=dev.example.com; HttpOnly; Secure; Max-Age=2592000"
      result = @instance.parse_cookie_value(cookie_header, 'DSR')
      expect(result).to eq(jwt_token)
    end

    it 'returns nil when cookie name is not found' do
      cookie_header = 'OTHER=value; Path=/; Domain=example.com'
      result = @instance.parse_cookie_value(cookie_header, 'DS')
      expect(result).to be_nil
    end

    it 'handles cookie value with special characters' do
      cookie_header = 'DS=token.with-special_chars123; Path=/; Domain=example.com'
      result = @instance.parse_cookie_value(cookie_header, 'DS')
      expect(result).to eq('token.with-special_chars123')
    end

    it 'handles cookie header with spaces around value' do
      cookie_header = 'DS= spaced_token ; Path=/; Domain=example.com'
      result = @instance.parse_cookie_value(cookie_header, 'DS')
      expect(result).to eq('spaced_token')
    end
  end

  describe '#safe_parse_json with cookie handling' do
    let(:mock_body) do
      {
        'userId' => 'test123',
        'cookieExpiration' => 1640704758,
        'cookieDomain' => 'dev.example.com'
      }.to_json
    end

    context 'when RestClient cookies are available (same domain)' do
      it 'uses RestClient cookies when available' do
        mock_cookies = {
          'DS' => 'session_token_from_restclient',
          'DSR' => 'refresh_token_from_restclient'
        }

        result = @instance.safe_parse_json(mock_body, cookies: mock_cookies, headers: {})
        
        expect(result['cookies']).to eq(mock_cookies)
        expect(result['cookies']['DS']).to eq('session_token_from_restclient')
        expect(result['cookies']['DSR']).to eq('refresh_token_from_restclient')
      end

      it 'handles only refresh token in RestClient cookies' do
        mock_cookies = { 'DSR' => 'refresh_token_only' }

        result = @instance.safe_parse_json(mock_body, cookies: mock_cookies, headers: {})
        
        expect(result['cookies']).to eq(mock_cookies)
        expect(result['cookies']['DSR']).to eq('refresh_token_only')
        expect(result['cookies']['DS']).to be_nil
      end
    end

    context 'when RestClient cookies are empty (custom domain)' do
      let(:set_cookie_headers) do
        [
          'DS=session_jwt_token; Path=/; Domain=dev.example.com; HttpOnly; Secure; SameSite=None',
          'DSR=refresh_jwt_token; Path=/; Domain=dev.example.com; HttpOnly; Secure; SameSite=None; Max-Age=2592000'
        ]
      end

      it 'parses cookies from Set-Cookie headers when RestClient cookies are empty' do
        mock_headers = { 'set-cookie' => set_cookie_headers }

        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: mock_headers)
        
        expect(result['cookies']).to_not be_nil
        expect(result['cookies']['DS']).to eq('session_jwt_token')
        expect(result['cookies']['DSR']).to eq('refresh_jwt_token')
      end

      it 'parses cookies from Set-Cookie header when headers is a string' do
        mock_headers = { 'Set-Cookie' => set_cookie_headers.first }

        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: mock_headers)
        
        expect(result['cookies']).to_not be_nil
        expect(result['cookies']['DS']).to eq('session_jwt_token')
      end

      it 'handles case-insensitive Set-Cookie header names' do
        mock_headers = { 'Set-Cookie' => set_cookie_headers }

        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: mock_headers)
        
        expect(result['cookies']['DS']).to eq('session_jwt_token')
        expect(result['cookies']['DSR']).to eq('refresh_jwt_token')
      end

      it 'handles complex JWT tokens in Set-Cookie headers' do
        jwt_session = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbSJ9.session_sig'
        jwt_refresh = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5kZXNjb3BlLmNvbSJ9.refresh_sig'
        
        complex_headers = [
          "DS=#{jwt_session}; Path=/; Domain=custom.example.com; HttpOnly; Secure; SameSite=None",
          "DSR=#{jwt_refresh}; Path=/; Domain=custom.example.com; HttpOnly; Secure; SameSite=None; Max-Age=2592000"
        ]
        mock_headers = { 'set-cookie' => complex_headers }

        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: mock_headers)
        
        expect(result['cookies']['DS']).to eq(jwt_session)
        expect(result['cookies']['DSR']).to eq(jwt_refresh)
      end

      it 'ignores non-Descope cookies in Set-Cookie headers' do
        mixed_headers = [
          'DS=session_token; Path=/; Domain=dev.example.com; HttpOnly',
          'CLOUDFLARE_SESSION=cf_token; Path=/; Domain=.example.com; HttpOnly',
          'DSR=refresh_token; Path=/; Domain=dev.example.com; HttpOnly'
        ]
        mock_headers = { 'set-cookie' => mixed_headers }

        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: mock_headers)
        
        expect(result['cookies']['DS']).to eq('session_token')
        expect(result['cookies']['DSR']).to eq('refresh_token')
        expect(result['cookies']['CLOUDFLARE_SESSION']).to be_nil
      end
    end

    context 'when no cookies are available anywhere' do
      it 'does not add cookies key to response' do
        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: {})
        
        expect(result).not_to have_key('cookies')
      end

      it 'handles missing Set-Cookie headers gracefully' do
        mock_headers = { 'content-type' => 'application/json' }

        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: mock_headers)
        
        expect(result).not_to have_key('cookies')
        expect(result['userId']).to eq('test123')
      end

      it 'handles nil headers gracefully' do
        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: nil)
        
        expect(result).not_to have_key('cookies')
        expect(result['userId']).to eq('test123')
      end
    end

    context 'edge cases' do
      it 'handles malformed Set-Cookie headers' do
        malformed_headers = [
          'MALFORMED_COOKIE_NO_EQUALS',
          'DS=; Path=/; Domain=example.com',  # Empty value
          '=value_without_name; Path=/',       # No name
        ]
        mock_headers = { 'set-cookie' => malformed_headers }

        result = @instance.safe_parse_json(mock_body, cookies: {}, headers: mock_headers)
        
        # Should handle gracefully and not crash
        expect(result['userId']).to eq('test123')
      end

      it 'prefers RestClient cookies over Set-Cookie headers when both available' do
        mock_cookies = { 'DS' => 'restclient_token' }
        set_cookie_headers = ['DS=header_token; Path=/; Domain=example.com']
        mock_headers = { 'set-cookie' => set_cookie_headers }

        result = @instance.safe_parse_json(mock_body, cookies: mock_cookies, headers: mock_headers)
        
        # Should prefer RestClient cookies
        expect(result['cookies']['DS']).to eq('restclient_token')
      end
    end
  end

  describe 'integration with request method' do
    it 'passes headers parameter to safe_parse_json' do
      # Mock RestClient response with custom domain cookies
      mock_response = double('response')
      allow(mock_response).to receive(:code).and_return(200)
      allow(mock_response).to receive(:body).and_return('{"success": true}')
      allow(mock_response).to receive(:cookies).and_return({})
      allow(mock_response).to receive(:headers).and_return({
        'set-cookie' => ['DS=test_token; Domain=custom.example.com']
      })

      allow(@instance).to receive(:call).and_return(mock_response)

      result = @instance.request(:get, '/test', {}, {})
      
      expect(result['cookies']).to_not be_nil
      expect(result['cookies']['DS']).to eq('test_token')
    end
  end
end