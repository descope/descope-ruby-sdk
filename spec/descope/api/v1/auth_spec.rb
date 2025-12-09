# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Descope::Api::V1::Auth do
  let(:client) { Class.new { include Descope::Api::V1::Auth }.new }
  let(:valid_token) { 'valid_token' }
  let(:refresh_token) { 'refresh_token' }

  describe 'token extraction with empty strings' do
    it 'handles empty string tokens correctly' do
      response_body = {
        'sessionJwt' => '',
        'refreshJwt' => '',
        'cookies' => {
          'DS' => valid_token,
          'DSR' => refresh_token
        }
      }

      allow(client).to receive(:validate_token).and_return({ 'sub' => 'user123', 'iss' => 'test_project_id' })

      result = client.generate_jwt_response(response_body: response_body)

      expect(result).to have_key('sessionToken')
      expect(result).to have_key('refreshSessionToken')
    end
  end
end