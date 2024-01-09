# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::MagicLink do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::MagicLink)
    @instance = dummy_instance
  end

  context '.sign_in' do
    it 'is expected to respond to sign in' do
      expect(@instance).to respond_to(:magiclink_sign_in)
    end

    it 'is expected to sign in with magic link email' do
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
        magiclink_compose_signin_url,
        request_params,
        {},
        'refresh_token'
      )

      allow_any_instance_of(Descope::Api::V1::Auth::MagicLink).to receive(:extract_masked_address).and_return({})

      expect do
        @instance.magiclink_sign_in(
          method: DeliveryMethod::EMAIL,
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

    it 'is expected to sign in with magic link phone' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/sms',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        },
      }
      expect(@instance).to receive(:post).with(
        magiclink_compose_signin_url(DeliveryMethod::SMS),
        request_params,
        {},
        'refresh_token'
      )

      allow_any_instance_of(Descope::Api::V1::Auth::MagicLink).to receive(:extract_masked_address).and_return(
        {
          'maskedPhone' => '+1******890'
        }
      )

      expect do
        @instance.magiclink_sign_in(
          method: DeliveryMethod::SMS,
          login_id: 'test',
          uri: 'https://some-uri/sms',
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
  end

  context '.sign_up' do
    it 'is expected to respond to magic link email sign up' do
      expect(@instance).to respond_to(:magiclink_sign_up)
    end

    it 'is expected to sign up with magic link via email' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/email',
        user: { username: 'user1', email: 'dummy@dummy.com' },
        email: 'dummy@dummy.com'
      }

      expect(@instance).to receive(:post).with(
        magiclink_compose_signup_url,
        request_params
      ).and_return({ 'maskedEmail' => 'd****@d****.com' })

      expect do
        @instance.magiclink_sign_up(
          login_id: 'test',
          method: DeliveryMethod::EMAIL,
          uri: 'https://some-uri/email',
          user: { username: 'user1', email: 'dummy@dummy.com' }
        )
      end.not_to raise_error
    end

    it 'is expected to sign up with magic link via phone' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/sms',
        user: { username: 'user1', phone: '+1234567890' },
        phone: '+1234567890'
      }

      expect(@instance).to receive(:post).with(
        magiclink_compose_signup_url(DeliveryMethod::SMS),
        request_params
      ).and_return({ 'maskedPhone' => '+1******890' })

      expect do
        @instance.magiclink_sign_up(
          login_id: 'test',
          method: DeliveryMethod::SMS,
          uri: 'https://some-uri/sms',
          user: { username: 'user1', phone: '+1234567890' }
        )
      end.not_to raise_error
    end
  end

  context '.sign_up_or_in' do
    it 'is expected to respond to sign up' do
      expect(@instance).to respond_to(:magiclink_sign_up_or_in)
    end

    it 'is expected to sign up or in with magic link' do
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
        magiclink_compose_sign_up_or_in_url,
        request_params
      ).and_return({ 'maskedEmail' => 'd****@d****.com' })

      expect do
        @instance.magiclink_sign_up_or_in(
          method: DeliveryMethod::EMAIL,
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

  context '.magiclink_verify_token' do
    it 'is expected to respond to magiclink_email_verify_token' do
      expect(@instance).to respond_to(:magiclink_verify_token)
    end

    it 'is expected to verify token with enchanted link' do
      expect(@instance).to receive(:post).with(
        VERIFY_MAGICLINK_AUTH_PATH,
        { token: 'token' }
      )

      expect { @instance.magiclink_verify_token('token') }.not_to raise_error
    end
  end

  context '.magiclink_update_email' do
    it 'is expected to respond to magiclink_email_update_user_email' do
      expect(@instance).to respond_to(:magiclink_update_user_email)
    end

    it 'is expected to update email with enchanted link' do
      request_params = {
        loginId: 'test',
        email: 'dummy@dummy.com',
        addToLoginIDs: true,
        onMergeUseExisting: true
      }

      expect(@instance).to receive(:post).with(
        UPDATE_USER_EMAIL_MAGICLINK_PATH,
        request_params,
        {},
        'token'
      ).and_return({ 'maskedEmail' => 'd****@d****.com' })

      expect do
        @instance.magiclink_update_user_email(
          login_id: 'test',
          email: 'dummy@dummy.com',
          add_to_login_ids: true,
          on_merge_use_existing: true,
          refresh_token: 'token'
        )
      end.not_to raise_error
    end
  end

  context '.magiclink_update_phone' do
    it 'is expected to respond to magiclink_email_update_user_phone' do
      expect(@instance).to respond_to(:magiclink_update_user_phone)
    end

    it 'is expected to update phone with enchanted link' do
      request_params = {
        loginId: 'test',
        phone: '+1234567890',
        addToLoginIDs: true,
        onMergeUseExisting: true,
        providerId: 'provider-id',
        templateId: 'template-id'
      }

      expect(@instance).to receive(:post).with(
        UPDATE_USER_PHONE_MAGICLINK_PATH,
        request_params,
        {},
        'token'
      ).and_return({ 'maskedPhone' => '+1******890' })

      expect do
        @instance.magiclink_update_user_phone(
          login_id: 'test',
          phone: '+1234567890',
          add_to_login_ids: true,
          on_merge_use_existing: true,
          refresh_token: 'token',
          method: DeliveryMethod::SMS,
          provider_id: 'provider-id',
          template_id: 'template-id'
        )
      end.not_to raise_error
    end
  end
end
