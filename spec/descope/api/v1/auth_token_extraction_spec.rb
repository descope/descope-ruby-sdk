# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Descope::Api::V1::Auth do
  let(:client) { Descope::Client.new(project_id: 'test_project_id', management_key: 'test_key') }
  let(:valid_session_token) { 'valid.session.token' }
  let(:valid_refresh_token) { 'valid.refresh.token' }

  describe '#generate_auth_info (private method)' do
    context 'session token extraction' do
      it 'extracts session token from sessionJwt field' do
        response_body = {
          'sessionJwt' => valid_session_token,
          'refreshJwt' => valid_refresh_token,
          'cookies' => {}
        }

        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

        result = client.send(:generate_auth_info, response_body, nil, true, nil)

        expect(result).to have_key('sessionToken')
      end

      it 'extracts session token from cookies with DS name' do
        response_body = {
          'sessionJwt' => '',
          'refreshJwt' => valid_refresh_token,
          'cookies' => {
            'DS' => valid_session_token
          }
        }

        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

        result = client.send(:generate_auth_info, response_body, nil, true, nil)

        expect(result).to have_key('sessionToken')
      end

      it 'extracts session token from cookies with SESSION_COOKIE_NAME' do
        stub_const('Descope::Api::V1::Auth::SESSION_COOKIE_NAME', 'CustomSession')
        
        response_body = {
          'sessionJwt' => '',
          'refreshJwt' => valid_refresh_token,
          'cookies' => {
            'CustomSession' => valid_session_token
          }
        }

        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

        result = client.send(:generate_auth_info, response_body, nil, true, nil)

        expect(result).to have_key('sessionToken')
      end
    end

    context 'refresh token extraction' do
      it 'extracts refresh token from refreshJwt field' do
        response_body = {
          'sessionJwt' => valid_session_token,
          'refreshJwt' => valid_refresh_token,
          'cookies' => {}
        }

        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

        result = client.send(:generate_auth_info, response_body, nil, true, nil)

        expect(result).to have_key('refreshSessionToken')
      end

      it 'extracts refresh token from cookies when refreshJwt is empty' do
        stub_const('Descope::Api::V1::Auth::REFRESH_SESSION_COOKIE_NAME', 'DSR')
        
        response_body = {
          'sessionJwt' => valid_session_token,
          'refreshJwt' => '',
          'cookies' => {
            'DSR' => valid_refresh_token
          }
        }

        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

        result = client.send(:generate_auth_info, response_body, nil, true, nil)

        expect(result).to have_key('refreshSessionToken')
      end

      it 'falls back to parameter refresh token when cookie has empty string' do
        response_body = {
          'sessionJwt' => valid_session_token,
          'refreshJwt' => '',
          'cookies' => {
            'DSR' => ''
          }
        }

        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

        result = client.send(:generate_auth_info, response_body, valid_refresh_token, true, nil)

        expect(result).to have_key('refreshSessionToken')
        expect(client).to have_received(:validate_token).with(valid_refresh_token, nil)
      end

      it 'raises error when no refresh token is available' do
        response_body = {
          'sessionJwt' => valid_session_token,
          'refreshJwt' => '',
          'cookies' => {}
        }

        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

        expect {
          client.send(:generate_auth_info, response_body, nil, true, nil)
        }.to raise_error(Descope::AuthException, /Could not find refresh token/)
      end
    end
  end
end
