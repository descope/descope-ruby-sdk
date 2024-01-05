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
      expect(@instance).to respond_to(:magic_link_email_sign_in)
    end

    it 'is expected to sign in with magic link email' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/email',
        loginOptions: { 'abc': '123' }
      }
      expect(@instance).to receive(:post).with(
        compose_signin_url,
        request_params,
        {},
        'refresh_token'
      )

      allow_any_instance_of(Descope::Api::V1::Auth::MagicLink).to receive(:extract_masked_address).and_return({})

      expect do
        @instance.magic_link_email_sign_in(
          method: DeliveryMethod::EMAIL,
          login_id: 'test',
          uri: 'https://some-uri/email',
          login_options: { 'abc': '123' },
          refresh_token: 'refresh_token'
        )
      end.not_to raise_error
    end
  end

  context '.sign_up' do
    it 'is expected to respond to magic link email sign up' do
      expect(@instance).to respond_to(:magic_link_email_sign_up)
    end

    it 'is expected to sign up with enchanted link' do
      request_params = {
        loginId: 'test',
        redirectUrl: 'https://some-uri/email',
        user: { username: 'user1', email: 'dummy@dummy.com' },
        email: 'dummy@dummy.com'
      }

      expect(@instance).to receive(:post).with(
        compose_signup_url,
        request_params
      ).and_return({ 'maskedEmail' => 'd****@d****.com' })

      expect do
        @instance.magic_link_email_sign_up(
          login_id: 'test',
          method: DeliveryMethod::EMAIL,
          uri: 'https://some-uri/email',
          user: { username: 'user1', email: 'dummy@dummy.com' }
        )
      end.not_to raise_error
    end
  end

  # context '.sign_up_or_in' do
  #   it 'is expected to respond to sign up' do
  #     expect(@instance).to respond_to(:magic_link_email_sign_up_or_in)
  #   end
  #
  #   it 'is expected to sign up with magic link' do
  #     request_params = {
  #       loginId: 'test',
  #       redirectUrl: 'https://some-uri/email',
  #       loginOptions: {}
  #     }
  #
  #     expect(@instance).to receive(:post).with(
  #       compose_sign_up_or_in_url,
  #       request_params
  #     )
  #
  #     expect do
  #       @instance.magic_link_email_sign_up_or_in(
  #         login_id: 'test',
  #         uri: 'https://some-uri/email'
  #       )
  #     end.not_to raise_error
  #   end
  # end
  #
  # context '.magic_link_verify_token' do
  #   it 'is expected to respond to magic_link_email_verify_token' do
  #     expect(@instance).to respond_to(:magic_link_email_verify_token)
  #   end
  #
  #   it 'is expected to verify token with enchanted link' do
  #     expect(@instance).to receive(:post).with(
  #       VERIFY_ENCHANTEDLINK_AUTH_PATH,
  #       { token: 'token' }
  #     )
  #
  #     expect { @instance.magic_link_email_verify_token(token: 'token') }.not_to raise_error
  #   end
  # end

  # context '.get_session' do
  #   it 'is expected to respond to get_session' do
  #     expect(@instance).to respond_to(:magic_link_email_get_session)
  #   end
  #
  #   it 'is expected to get session by pending ref with enchanted link' do
  #     jwt_response = { 'fake': 'response' }
  #     allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)
  #
  #     expect do
  #       @instance.magic_link_email_get_session(pending_ref: 'pendingRef')
  #     end.not_to raise_error
  #   end
  # end
end
