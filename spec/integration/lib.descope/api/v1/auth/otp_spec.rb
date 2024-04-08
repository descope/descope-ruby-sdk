# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Auth::OTP do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)

    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::OTP)
    @instance = dummy_instance
    @user = build(:user)
    @test_user = @client.create_test_user(**@user)['user']
    @client.create_test_user(**@user)
  end

  after(:all) do
    @client.logger.info('Cleaning up test users...')
    all_users = @client.search_all_users
    all_users['users'].each do |user|
      if user['middleName'] == 'Ruby SDK User'
        @client.logger.info("Deleting ruby spec test user #{user['loginIds'][0]}")
        @client.delete_user(user['loginIds'][0])
      end
    end
  end

  # SIGN INs
  context 'test otp sign-in methods' do
    it 'should sign in a new test user with otp via EMAIL' do
      res = @client.generate_otp_for_test_user(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
        login_id: @test_user['loginIds'][0]
      )
      @client.logger.info("res: #{res}")
      @client.otp_verify_code(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
        login_id: @user[:login_id],
        code: res['code']
      )
    end

    it 'should sign in a new test user with otp via SMS' do
      res = @client.generate_otp_for_test_user(
        method: Descope::Mixins::Common::DeliveryMethod::SMS,
        login_id: @test_user['loginIds'][0]
      )
      @client.logger.info("res: #{res}")
      @client.otp_verify_code(
        method: Descope::Mixins::Common::DeliveryMethod::SMS,
        login_id: @user[:login_id],
        code: res['code']
      )
    end
  end

  # SIGN UPs
  context 'test otp sign-up methods' do
    it 'should sign up with otp via email' do
      email = 'someone@example.com'
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:extract_masked_address).and_return({})
      expect(@instance).to receive(:post).with(
        otp_compose_signup_url, { loginId: email, email: '' }
      )

      expect do
        @instance.otp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: email)
      end.not_to raise_error
    end

    it 'should sign up with otp via SMS' do
      phone = '+12123354465'
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:extract_masked_address).and_return({})
      expect(@instance).to receive(:post).with(
        otp_compose_signup_url(Descope::Mixins::Common::DeliveryMethod::SMS), { loginId: phone, phone: '' }
      )

      expect do
        @instance.otp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::SMS, login_id: phone)
      end.not_to raise_error
    end

    it 'should sign up with otp via voice' do
      phone = '+12123354465'
      allow_any_instance_of(Descope::Api::V1::Auth).to receive(:extract_masked_address).and_return({})
      expect(@instance).to receive(:post).with(
        otp_compose_signup_url(Descope::Mixins::Common::DeliveryMethod::VOICE), { loginId: phone, phone: '' }
      )

      expect do
        @instance.otp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::VOICE, login_id: phone)
      end.not_to raise_error
    end

    it 'should fail to signup with invalid phone number via SMS' do
      phone = '1$234.90'
      expect do
        @instance.otp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::SMS, login_id: phone)
      end.to raise_error(Descope::AuthException, "Invalid pattern for phone number: #{phone}")
    end
  end
end
