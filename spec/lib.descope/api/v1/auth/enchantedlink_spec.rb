# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::EnchantedLink do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::EnchantedLink)
    @instance = dummy_instance
  end

  context '.sign_in' do
    it 'is expected to respond to sign in' do
      expect(@instance).to respond_to(:enchanted_link_sign_in)
    end

    it 'is expected to sign in with enchanted link' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/email',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        }
      }
      expect(@instance).to receive(:post).with(
        enchanted_link_compose_signin_url,
        request_params,
        nil,
        'refresh_token'
      )

      expect do
        @instance.enchanted_link_sign_in(
          login_id: 'test',
          uri: 'https://some-uri/email',
          login_options: {
            stepup: false,
            custom_claims: { 'abc': '123' },
            mfa: false,
            sso_app_id: 'sso-id'
          },
          refresh_token: 'refresh_token'
        )
      end.not_to raise_error
    end

    it 'is expected to validate refresh token and not raise an error with refresh token and valid login options' do
      expect do
        @instance.send(:validate_refresh_token_provided, { mfa: true, stepup: true },  'some-token')
      end.not_to raise_error
    end

    it 'is expected to validate refresh token and raise an error with refresh token and invalid login options' do
      expect do
        @instance.send(:validate_refresh_token_provided, { mfa: true, stepup: true }, '')
      end.to raise_error(Descope::AuthException, 'Missing refresh token for stepup/mfa')
    end
  end

  context '.sign_up' do
    it 'is expected to respond to sign up' do
      expect(@instance).to respond_to(:enchanted_link_sign_up)
    end

    it 'is expected to sign up with enchanted link' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/email',
        user: { username: 'user1', email: 'dummy@dummy.com' },
        email: 'dummy@dummy.com'
      }

      expect(@instance).to receive(:post).with(
        enchanted_link_compose_signup_url,
        request_params
      )

      expect do
        @instance.enchanted_link_sign_up(
          login_id: 'test',
          uri: 'https://some-uri/email',
          user: { username: 'user1', email: 'dummy@dummy.com' }
        )
      end.not_to raise_error
    end
  end

  context '.sign_up_or_in' do
    it 'is expected to respond to sign up' do
      expect(@instance).to respond_to(:enchanted_link_sign_up_or_in)
    end

    it 'is expected to sign up with enchanted link' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/email',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        }
      }

      expect(@instance).to receive(:post).with(
        enchanted_link_compose_sign_up_or_in_url,
        request_params
      )

      expect do
        @instance.enchanted_link_sign_up_or_in(
          login_id: 'test',
          uri: 'https://some-uri/email',
          login_options: {
            stepup: false,
            custom_claims: { 'abc': '123' },
            mfa: false,
            sso_app_id: 'sso-id'
          }
        )
      end.not_to raise_error
    end
  end

  context '.enchanted_link_verify_token' do
    it 'is expected to respond to enchanted_link_verify_token' do
      expect(@instance).to respond_to(:enchanted_link_verify_token)
    end

    it 'is expected to verify token with enchanted link' do
      expect(@instance).to receive(:post).with(
        VERIFY_ENCHANTEDLINK_AUTH_PATH,
        { token: 'token' }
      )

      expect { @instance.enchanted_link_verify_token('token') }.not_to raise_error
    end
  end

  context '.get_session' do
    it 'is expected to respond to get_session' do
      expect(@instance).to respond_to(:enchanted_link_get_session)
    end

    it 'is expected to get session by pending ref with enchanted link' do
      jwt_response = { 'fake': 'response' }
      allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)

      expect do
        @instance.enchanted_link_get_session(pending_ref: 'pendingRef')
      end.not_to raise_error
    end
  end
end
