# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Session do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Mixins::Common::EndpointsV1)
    @instance = dummy_instance
  end

  context '.token_validation_key' do
    it 'is expected to respond to token validation key' do
      expect(@instance).to respond_to(:token_validation_key)
    end

    it 'is expected to get v2 public key' do
      project_id = 'project123'
      expect(@instance).to receive(:get).with(
        "#{Descope::Mixins::Common::EndpointsV2::PUBLIC_KEY_PATH}/#{project_id}"
      )

      expect { @instance.token_validation_key('project123') }.not_to raise_error
    end
  end

  context '.refresh_session' do
    it 'is expected to respond to refresh session' do
      expect(@instance).to respond_to(:refresh_session)
    end

    it 'is expected to post refresh session' do
      jwt_response = {
        'sessionJwt' => 'fake_session_jwt',
        'refreshJwt' => 'fake_refresh_jwt',
        'cookies' => {
          'refresh_token' => 'fake_refresh_cookie'
        }
      }
      refresh_token = 'refresh_token'
      audience = nil

      allow(@instance).to receive(:validate_refresh_token_not_nil).with(refresh_token).and_return(true)
      allow(@instance).to receive(:validate_token).with(refresh_token, audience).and_return(true)
      allow(@instance).to receive(:post).with(REFRESH_TOKEN_PATH, {}, {}, refresh_token).and_return(jwt_response)
      refresh_cookie = jwt_response['cookies'][REFRESH_SESSION_COOKIE_NAME] || jwt_response['refreshJwt']

      allow(@instance).to receive(:generate_jwt_response).with(
        response_body: jwt_response,
        refresh_cookie:,
        audience:
      ).and_return(jwt_response)

      expect { @instance.refresh_session(refresh_token:, audience:) }.not_to raise_error

      # Optionally verify the response if needed
      result = @instance.refresh_session(refresh_token:, audience:)
      expect(result).to eq(jwt_response)
    end
  end

  context '.me' do
    it 'is expected to respond to /me' do
      expect(@instance).to respond_to(:me)
    end

    it 'is expected to get /me' do
      expect(@instance).to receive(:get).with(ME_PATH, {}, {}, nil)

      expect { @instance.me }.not_to raise_error
    end
  end

  context '.sign_out' do
    it 'is expected to respond to sign out' do
      expect(@instance).to respond_to(:sign_out)
    end

    it 'is expected to post sign out' do
      expect(@instance).to receive(:post).with(LOGOUT_PATH, {}, {}, nil)

      expect { @instance.sign_out }.not_to raise_error
    end
  end

  context '.sign_out_all' do
    it 'is expected to respond to sign out all' do
      expect(@instance).to respond_to(:sign_out_all)
    end

    it 'is expected to post sign out all' do
      expect(@instance).to receive(:post).with(LOGOUT_ALL_PATH, {}, {}, nil)

      expect { @instance.sign_out_all }.not_to raise_error
    end
  end

  context '.validate_session' do
    it 'is expected to respond to validate session' do
      expect(@instance).to respond_to(:validate_session)
    end

    it 'is expected to raise error if session token is nil' do
      expect { @instance.validate_session }.to raise_error(
        Descope::AuthException,
        'Session token is required for validation'
      )
    end

    it 'is expected to raise error if session token is empty' do
      expect { @instance.validate_session(session_token: '') }.to raise_error(
        Descope::AuthException,
        'Session token is required for validation'
      )
    end

  end

  context '.validate_and_refresh_session' do
    it 'is expected to respond to validate and refresh session' do
      expect(@instance).to respond_to(:validate_and_refresh_session)
    end

    it 'is expected to try and validate session or refresh session' do
      expect { @instance.validate_and_refresh_session(session_token: 'invalid_session_token') }.to raise_error(
        Descope::AuthException,
        'Refresh token is required to refresh a session'
      )
      allow(@instance).to receive(:validate_session).with(session_token: 'session_token', audience: nil).and_raise(Descope::AuthException).and_return({})
      jwt_response = { 'fake': 'response' }
      allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)
      allow(@instance).to receive(:refresh_session).and_return({})
      expect { @instance.validate_and_refresh_session(session_token: 'session_token', refresh_token: 'refresh_token') }.to_not raise_error
    end
  end
end
