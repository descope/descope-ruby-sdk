# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::OTP do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::OTP)
    @instance = dummy_instance
  end

  context '.sign_in' do
    it 'is expected to respond to sign in using otp' do
      expect(@instance).to respond_to(:totp_sign_in_code)
    end

    it 'is expected to sign in with totp code' do
      request_params = {
        loginId: 'test',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        },
        code: '123456'
      }
      jwt_response = { 'fake': 'response' }
      allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)
      expect(@instance).to receive(:post).with(VERIFY_TOTP_PATH, request_params, {}, 'refresh_token').and_return(
        jwt_response
      )

      expect do
        @instance.totp_sign_in_code(
          login_id: 'test',
          login_options: {
            stepup: false,
            custom_claims: { 'abc': '123' },
            mfa: false,
            sso_app_id: 'sso-id'
          },
          code: '123456',
          refresh_token: 'refresh_token'
        )
      end.not_to raise_error
    end
  end

  context '.totp_add_update_key' do
    it 'is expected to respond to totp_add_update_key' do
      expect(@instance).to respond_to(:totp_add_update_key)
    end

    it 'is expected to add or update totp key' do
      request_params = {
        loginId: 'test'
      }

      allow(@instance).to receive(:post).with(UPDATE_TOTP_PATH, request_params, {}, 'refresh_token')

      expect do
        @instance.totp_add_update_key(
          login_id: 'test',
          refresh_token: 'refresh_token'
        )
      end.not_to raise_error
    end
  end
end
