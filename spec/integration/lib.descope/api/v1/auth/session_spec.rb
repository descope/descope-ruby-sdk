# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Session do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
  end

  after(:all) do
    @client.logger.info('Cleaning up test users...')
    all_users = @client.search_all_users
    all_users['users'].each do |user|
      if user['middleName'] == "#{SpecUtils.build_prefix}Ruby-SDK-User" 
        @client.logger.info("Deleting ruby spec test user #{user['loginIds'][0]}")
        @client.delete_user(user['loginIds'][0])
      end
    end
  end

  context 'test session methods' do
    it 'should refresh session with refresh token' do
      @password = SpecUtils.generate_password
      user = build(:user)

      @client.logger.info('1. Sign up with password')
      res = @client.password_sign_up(login_id: user[:login_id], password: @password, user:)
      @client.logger.info("sign up with password res: #{res}")
      original_refresh_token = res[REFRESH_SESSION_TOKEN_NAME]['jwt']

      @client.logger.info('2. Sign in with password')
      login_res = @client.password_sign_in(login_id: user[:login_id], password: @password)
      @client.logger.info("sign_in res: #{login_res}")

      @client.logger.info('3. Wait briefly to ensure token timestamps differ')
      sleep(2)  # Wait 2 seconds to ensure new token will have different 'iat' timestamp

      @client.logger.info('4. Refresh session')
      refresh_session_res = @client.refresh_session(refresh_token: login_res[REFRESH_SESSION_TOKEN_NAME]['jwt'])
      @client.logger.info("refresh_session_res: #{refresh_session_res}")

      new_refresh_token = refresh_session_res[REFRESH_SESSION_TOKEN_NAME]['jwt']
      @client.logger.info("new_refresh_token: #{new_refresh_token}")

      @client.logger.info('5. Check new refresh token is not the same as the original one')
      expect(original_refresh_token).not_to eq(new_refresh_token)
    end
  end
end
