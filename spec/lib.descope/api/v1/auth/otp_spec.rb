# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::OTP do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::OTP)
    dummy_instance.extend(Descope::Api::V1::Management::User)
    @instance = dummy_instance
  end

  # Sign In methods
  context '.sign_in' do
    it 'is expected to respond to sign in using otp' do
      expect(@instance).to respond_to(:otp_sign_in)
    end

    it 'is expected to sign in with otp with email' do
      request_params = {
        loginId: 'dummy@dummy.com',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        }
      }
      expect(@instance).to receive(:post).with(
        otp_compose_signin_url,
        request_params,
        {},
        'refresh_token'
      )

      allow_any_instance_of(Descope::Api::V1::Auth::OTP).to receive(:extract_masked_address).and_return({})

      expect do
        @instance.otp_sign_in(
          method: DeliveryMethod::EMAIL,
          login_id: 'dummy@dummy.com',
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

    it 'is expected to sign in with otp phone SMS' do
      request_params = {
        loginId: '+12122242225',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        }
      }
      expect(@instance).to receive(:post).with(
        otp_compose_signin_url(DeliveryMethod::SMS),
        request_params,
        {},
        'refresh_token'
      )

      allow_any_instance_of(Descope::Api::V1::Auth::OTP).to receive(:extract_masked_address).and_return(
        {
          'maskedPhone' => '+1******890'
        }
      )

      expect do
        @instance.otp_sign_in(
          method: DeliveryMethod::SMS,
          login_id: '+12122242225',
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

    it 'is expected to sign in with otp Voice' do
      request_params = {
        loginId: '+12122242225',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        }
      }
      expect(@instance).to receive(:post).with(
        otp_compose_signin_url(DeliveryMethod::VOICE),
        request_params,
        {},
        'refresh_token'
      )

      allow_any_instance_of(Descope::Api::V1::Auth::OTP).to receive(:extract_masked_address).and_return(
        {
          'maskedPhone' => '+1******890'
        }
      )

      expect do
        @instance.otp_sign_in(
          method: DeliveryMethod::VOICE,
          login_id: '+12122242225',
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

  # Sign Up methods
  context '.sign_up' do
    it 'is expected to respond to otp email sign up' do
      expect(@instance).to respond_to(:otp_sign_up)
    end

    it 'is expected to sign up with otp via email' do
      request_params = {
        loginId: 'user1',
        user: { loginId: 'user1', email: 'dummy@dummy.com' },
        email: 'dummy@dummy.com'
      }

      expect(@instance).to receive(:post).with(
        otp_compose_signup_url,
        request_params
      ).and_return({ 'maskedEmail' => 'd****@d****.com' })

      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:extract_masked_address).and_return({})

      expect do
        @instance.otp_sign_up(
          login_id: 'user1',
          method: DeliveryMethod::EMAIL,
          user: { login_id: 'user1', email: 'dummy@dummy.com' }
        )
      end.not_to raise_error
    end

    it 'is expected to sign up with otp via SMS' do
      request_params = {
        loginId: '+1234567890',
        user: { loginId: '+1234567890' },
        phone: ''
      }

      expect(@instance).to receive(:post).with(
        otp_compose_signup_url(DeliveryMethod::SMS),
        request_params
      ).and_return({ 'maskedPhone' => '+1******890' })

      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:extract_masked_address).and_return({})

      expect do
        @instance.otp_sign_up(
          login_id: '+1234567890',
          method: DeliveryMethod::SMS,
          user: { login_id: '+1234567890' }
        )
      end.not_to raise_error
    end

    it 'is expected to sign up with otp via Voice' do
      request_params = {
        loginId: '+1234567890',
        user: { loginId: '+1234567890', phone: '+1234567890' },
        phone: '+1234567890'
      }

      expect(@instance).to receive(:post).with(
        otp_compose_signup_url(DeliveryMethod::VOICE),
        request_params
      ).and_return({ 'maskedPhone' => '+1******890' })

      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:extract_masked_address).and_return({})

      expect do
        @instance.otp_sign_up(
          login_id: '+1234567890',
          method: DeliveryMethod::VOICE,
          user: { login_id: '+1234567890', phone: '+1234567890' }
        )
      end.not_to raise_error
    end
  end

  # Sign Up or In methods
  context '.sign_up_or_in' do
    it 'is expected to respond to sign up' do
      expect(@instance).to respond_to(:otp_sign_up_or_in)
    end

    it 'is expected to sign up or in with otp via email' do
      request_params = {
        loginId: 'dummy@dummy.com',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        },
        providerId: 'provider-id',
        templateId: 'template-id',
        ssoAppId: 'sso-id'
      }

      expect(@instance).to receive(:post).with(
        otp_compose_sign_up_or_in_url,
        request_params
      ).and_return({ 'maskedEmail' => 'd****@d****.com' })

      expect do
        @instance.otp_sign_up_or_in(
          method: DeliveryMethod::EMAIL,
          login_id: 'dummy@dummy.com',
          login_options: {
            stepup: false,
            custom_claims: { 'abc': '123' },
            mfa: false,
            sso_app_id: 'sso-id'
          },
          provider_id: 'provider-id',
          template_id: 'template-id',
          sso_app_id: 'sso-id'
        )
      end.not_to raise_error
    end

    it 'is expected to sign up or in with otp via SMS' do
      request_params = {
        loginId: '+12122242225',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        },
        providerId: 'provider-id',
        templateId: 'template-id',
        ssoAppId: 'sso-id'
      }

      expect(@instance).to receive(:post).with(
        otp_compose_sign_up_or_in_url(DeliveryMethod::SMS),
        request_params
      ).and_return({ 'maskedPhone' => '+1******890' })

      expect do
        @instance.otp_sign_up_or_in(
          method: DeliveryMethod::SMS,
          login_id: '+12122242225',
          login_options: {
            stepup: false,
            custom_claims: { 'abc': '123' },
            mfa: false,
            sso_app_id: 'sso-id'
          },
          provider_id: 'provider-id',
          template_id: 'template-id',
          sso_app_id: 'sso-id'
        )
      end.not_to raise_error
    end

    it 'is expected to sign up or in with otp via Voice' do
      request_params = {
        loginId: '+12122242225',
        loginOptions: {
          stepup: false,
          customClaims: { 'abc': '123' },
          mfa: false,
          ssoAppId: 'sso-id'
        },
        providerId: 'provider-id',
        templateId: 'template-id',
        ssoAppId: 'sso-id'
      }

      expect(@instance).to receive(:post).with(
        otp_compose_sign_up_or_in_url(DeliveryMethod::VOICE),
        request_params
      ).and_return({ 'maskedPhone' => '+1******890' })

      expect do
        @instance.otp_sign_up_or_in(
          method: DeliveryMethod::VOICE,
          login_id: '+12122242225',
          login_options: {
            stepup: false,
            custom_claims: { 'abc': '123' },
            mfa: false,
            sso_app_id: 'sso-id'
          },
          provider_id: 'provider-id',
          template_id: 'template-id',
          sso_app_id: 'sso-id'
        )
      end.not_to raise_error
    end
  end

  context '.otp_verify_code' do
    it 'is expected to respond to otp_verify_code' do
      expect(@instance).to respond_to(:otp_verify_code)
    end

    it 'is expected to verify OTP code' do
      jwt_response = { 'fake': 'response' }
      allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)

      expect(@instance).to receive(:post).with(
        otp_compose_verify_code_url,
        {
          loginId: 'test',
          code: '123456'
        }
      ).and_return({ 'sessionJWT': 'fake-session-jwt' })

      expect do
        @instance.otp_verify_code(
          method: DeliveryMethod::EMAIL,
          login_id: 'test',
          code: '123456'
        )
      end.not_to raise_error
    end
  end

  context '.otp_update_email' do
    it 'is expected to respond to otp_email_update_user_email' do
      expect(@instance).to respond_to(:otp_update_user_email)
    end

    it 'raises a validation error' do
      expect { OTP.otp_update_user_phone(login_id: nil) }
        .to raise_error('login_id cannot be empty')
    end

    it 'raises a validation error' do
      expect { OTP.otp_update_user_phone(login_id: 'someone', phone: nil) }
        .to raise_error('Phone number cannot be empty')
    end

    it 'raises a delivery method error with invalid method' do
      expect do
        OTP.otp_update_user_phone(login_id: 'abc', phone: '+12124332222', method: 0)
      end.to raise_error(Descope::AuthException, /Delivery method should be one of the following/)
    end

    it 'raises a validation error when phone number doesnt match pattern' do
      expect do
        OTP.otp_update_user_phone(login_id: 'abc', phone: '-1212a$', method: DeliveryMethod::SMS)
      end.to raise_error(Descope::AuthException, /Invalid pattern for phone number/)
    end

    it 'is expected to update email with otp' do
      request_params = {
        loginId: 'test',
        email: 'dummy@dummy.com',
        addToLoginIDs: true,
        onMergeUseExisting: true,
        providerId: 'provider-id',
        templateId: 'template-id'
      }

      expect(@instance).to receive(:post).with(
        UPDATE_USER_EMAIL_OTP_PATH,
        request_params,
        {},
        'token'
      ).and_return({ 'maskedEmail' => 'd****@d****.com' })

      expect do
        @instance.otp_update_user_email(
          login_id: 'test',
          email: 'dummy@dummy.com',
          add_to_login_ids: true,
          on_merge_use_existing: true,
          refresh_token: 'token',
          provider_id: 'provider-id',
          template_id: 'template-id'
        )
      end.not_to raise_error
    end
  end

  context '.otp_update_phone' do
    it 'is expected to respond to otp_email_update_user_phone' do
      expect(@instance).to respond_to(:otp_update_user_phone)
    end

    it 'is expected to update phone with otp' do
      request_params = {
        loginId: 'test',
        phone: '+1234567890',
        addToLoginIDs: true,
        onMergeUseExisting: true,
        providerId: 'provider-id',
        templateId: 'template-id'
      }

      expect(@instance).to receive(:post).with(
        otp_compose_update_phone_url(DeliveryMethod::SMS),
        request_params,
        {},
        'token'
      ).and_return({ 'maskedPhone' => '+1******890' })

      expect do
        @instance.otp_update_user_phone(
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
