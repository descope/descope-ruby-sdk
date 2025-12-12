# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Auth::MagicLink do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
  end

  after(:all) do
    @client.logger.info('Cleaning up test users...')
    all_users = @client.search_all_users
    all_users['users'].each do |user|
      if user['middleName'] == "#{SpecUtils.build_prefix}Ruby-SDK-User" 
        @client.logger.info("Deleting ruby spec test user #{user['loginIds'][0]}")
        begin
          @client.delete_user(user['loginIds'][0])
        rescue Descope::NotFound => e
          @client.logger.info("User already deleted: #{e.message}")
        end
      end
    end
  end

  context 'test Magiclink for test user' do
    it 'should sign in with magiclink' do
      user = build(:user)
      test_user = @client.create_test_user(**user)['user']
      @client.create_test_user(**user)
      res = @client.generate_magic_link_for_test_user(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
        login_id: test_user['loginIds'][0],
        uri: 'http://localhost:3000/verify'
      )
      @client.logger.info("res: #{res}")
      token = res['link'].match(/^http.+verify\?t=(.+)/)[1]
      @client.logger.info("token: #{token}")

      expect do
        @client.logger.info('Verifying token...')
        jwt_response = @client.magiclink_verify_token(token)
        @client.logger.info("jwt_response #{jwt_response}")
        my_details = @client.me(jwt_response['refreshSessionToken']['jwt'])
        @client.logger.info('verifying session...')
        expect(my_details['email']).to eq(test_user['email'])
        @client.logger.info('Magiclink Token Verified via sign in!')
      rescue StandardError => e
        raise StandardError, "Verification failed - Could not verify token: #{e.message}"

      end.to_not raise_error
    end
  end
end
