# frozen_string_literal: true

require 'spec_helper'
require 'rotp'

describe Descope::Api::V1::Auth::TOTP do
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

  context 'test totp methods' do
    it 'should sign up with totp' do
      # Initiate a TOTP sign-up process for a new end user.
      # Descope will generate a TOTP key (also called a secret or seed) that will be entered into the end user's
      # authenticator app so that TOTP codes can be successfully verified.
      # The new end user will be registered after the full TOTP sign-up flow has successfully completed.

      user = build(:user)

      @client.logger.info('1. Sign up TOTP')
      totp_key = @client.totp_sign_up(login_id: user[:login_id], user:)['key']
      totp = ROTP::TOTP.new(totp_key)
      p "Current OTP: #{totp.now}"

      @client.logger.info('2. TOTP sign in')
      login_res = @client.totp_sign_in_code(login_id: user[:login_id], code: totp.now)
      @client.logger.info("login_res: #{login_res}")
      refresh_token = login_res['refreshSessionToken']['jwt']

      @client.logger.info('3. Verify email')
      my_details = @client.me(refresh_token)
      expect(my_details['email']).to eq(user[:email])
    end

    it 'should add or update totp key' do
      # Add or update TOTP key for existing end user
      # Update the email address of an end user, after verifying the authenticity of the end user using OTP.

      user = build(:user)

      @client.logger.info('1. Sign up TOTP')
      totp_key = @client.totp_sign_up(login_id: user[:login_id], user:)['key']
      totp = ROTP::TOTP.new(totp_key)
      p "Current OTP: #{totp.now}"

      @client.logger.info('2. TOTP sign in')
      login_res = @client.totp_sign_in_code(login_id: user[:login_id], code: totp.now)
      @client.logger.info("login_res: #{login_res}")
      refresh_token = login_res['refreshSessionToken']['jwt']

      @client.logger.info('3. Add or update TOTP key')
      new_key = @client.totp_add_update_key(login_id: user[:login_id], refresh_token:)['key']
      new_totp = ROTP::TOTP.new(new_key)
      p "New OTP: #{totp.now}"

      @client.logger.info('4. TOTP sign in with new key')
      login_res = @client.totp_sign_in_code(login_id: user[:login_id], code: new_totp.now)
      refresh_token = login_res['refreshSessionToken']['jwt']

      @client.logger.info('5. Verify email')
      my_details = @client.me(refresh_token)
      expect(my_details['email']).to eq(user[:email])
    end
  end
end
