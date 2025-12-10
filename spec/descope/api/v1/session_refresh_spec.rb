# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Descope::Api::V1::Session do
  let(:client) { Descope::Client.new(project_id: 'test_project_id', management_key: 'test_key') }
  let(:valid_token) { 'valid.jwt.token' }
  let(:refresh_token) { 'refresh.jwt.token' }

  describe '#refresh_session' do
    context 'when refresh token is in cookie' do
      it 'uses the cookie refresh token' do
        response_body = {
          'sessionJwt' => '',
          'refreshJwt' => '',
          'cookieData' => {
            'DSR' => refresh_token
          },
          'cookies' => {
            'DS' => valid_token
          }
        }

        allow(client).to receive(:post).and_return(response_body)
        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123' })

        result = client.refresh_session(refresh_token: refresh_token)

        expect(result).to be_a(Hash)
        expect(client).to have_received(:validate_token).with(refresh_token, nil)
      end
    end

    context 'when refresh token is in response body' do
      it 'uses the refreshJwt from response body' do
        response_body = {
          'sessionJwt' => '',
          'refreshJwt' => refresh_token,
          'cookieData' => {},
          'cookies' => {
            'DS' => valid_token
          }
        }

        allow(client).to receive(:post).and_return(response_body)
        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123' })

        result = client.refresh_session(refresh_token: 'old_refresh_token')

        expect(result).to be_a(Hash)
      end
    end

    context 'when refresh token is only in parameter' do
      it 'falls back to the parameter refresh token' do
        response_body = {
          'sessionJwt' => '',
          'refreshJwt' => '',
          'cookieData' => {},
          'cookies' => {
            'DS' => valid_token
          }
        }

        allow(client).to receive(:post).and_return(response_body)
        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123' })

        result = client.refresh_session(refresh_token: refresh_token)

        expect(result).to be_a(Hash)
        expect(client).to have_received(:validate_token).with(refresh_token, nil).at_least(:once)
      end
    end

    context 'when refresh token values are empty strings' do
      it 'falls back to parameter refresh token when cookie and body have empty strings' do
        response_body = {
          'sessionJwt' => '',
          'refreshJwt' => '',
          'cookieData' => {
            'DSR' => ''
          },
          'cookies' => {
            'DS' => valid_token
          }
        }

        allow(client).to receive(:post).and_return(response_body)
        allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123' })

        result = client.refresh_session(refresh_token: refresh_token)

        expect(result).to be_a(Hash)
        expect(client).to have_received(:validate_token).with(refresh_token, nil).at_least(:once)
      end
    end
  end
end
