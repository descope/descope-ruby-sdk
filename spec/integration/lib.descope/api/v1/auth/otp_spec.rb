# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Auth::OTP do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
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

  context 'test otp sign-in with test user' do
    it 'should sign in with otp' do
      user = build(:user)
      test_user = @client.create_test_user(**user)['user']
      @client.create_test_user(**user)
      res = @client.generate_otp_for_test_user(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
        login_id: test_user['loginIds'][0]
      )
      @client.logger.info("res: #{res}")
      @client.otp_verify_code(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
        login_id: user[:login_id],
        code: res['code']
      )
    end
  end
end
