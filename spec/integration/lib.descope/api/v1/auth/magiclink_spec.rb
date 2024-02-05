# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Auth::MagicLink do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
    include Mailmock
    @mailmock = Mailmock::Mail.new
  end

  after(:all) do
    puts 'Cleaning up test users...'
    all_users = @client.search_all_users
    all_users['users'].each do |user|
      if user['middleName'] == 'Ruby SDK User' || user['email'].include?('aws.mailmock.io')
        puts "Deleting ruby spec test user #{user['loginIds'][0]}"
        @client.delete_user(user['loginIds'][0])
      end
    end
  end

  context 'test Magiclink methods' do
    it 'should sign up with magiclink' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.magiclink_sign_up(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], user:, uri: 'http://localhost:3000/verify')

      mail_response = @mailmock.wait_for_email
      token = mail_response.text.match(/^http.+verify\?t=(.+)/)[1]
      puts "token: #{token}"

      expect do
        begin
          jwt_response = @client.magiclink_verify_token(token)
          puts "jwt_response #{jwt_response}"
          my_details = @client.me(jwt_response['refreshJwt'])
          expect(my_details['email']).to eq(user[:email])
          puts 'Magiclink Token Verified via sign up!'
        rescue StandardError => e
          raise StandardError "Verification failed - Could not verify token: #{e.message}"
        end
      end.to_not raise_error
    end

    it 'should sign in with magiclink' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.create_user(**user)
      @client.magiclink_sign_in(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], uri: 'http://localhost:3000/verify')

      mail_response = @mailmock.wait_for_email
      token = mail_response.text.match(/^http.+verify\?t=(.+)/)[1]
      puts "token: #{token}"

      expect do
      begin
        jwt_response = @client.magiclink_verify_token(token)
        puts "jwt_response #{jwt_response}"
        my_details = @client.me(jwt_response['refreshJwt'])
        expect(my_details['email']).to eq(user[:email])
        puts 'Magiclink Token Verified via sign in!'
      rescue StandardError => e
        raise StandardError "Verification failed - Could not verify token: #{e.message}"
      end.to_not raise_error
    end

    it 'should sign up or in with magiclink' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.create_user(**user)
      @client.magiclink_sign_up_or_in(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], uri: 'http://localhost:3000/verify')
      mail_response = @mailmock.wait_for_email
      token = mail_response.text.match(/^http.+verify\?t=(.+)/)[1]
      puts "token: #{token}"

      expect do
      begin
        jwt_response = @client.magiclink_verify_token(token)
        puts "jwt_response #{jwt_response}"
        my_details = @client.me(jwt_response['refreshJwt'])
        expect(my_details['email']).to eq(user[:email])
        puts 'Magiclink Token Verified via sign up or in!'
      rescue StandardError => e
        raise StandardError "Verification failed - Could not verify token: #{e.message}"
      end.to_not raise_error
    end

    it 'should update email on magiclink' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      puts "Creating user #{user[:email]}..."
      @client.create_user(**user)

      # Sign in Magiclink
      puts "Signing in user #{user[:email]}..."
      @client.magiclink_sign_in(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], uri: 'http://localhost:3000/verify')
      mail_response = @mailmock.wait_for_email
      token = mail_response.text.match(/^http.+verify\?t=(.+)/)[1]
      puts "token: #{token}"

      expect do
      begin
        puts 'verifying token from magiclink...'
        jwt_response = @client.magiclink_verify_token(token)

        @mailbox_new = @mailmock.create_mailbox(user[:login_id], 'aws')
        puts 'Updating email Magiclink with refresh token'
        @client.magiclink_update_user_email(login_id: user[:login_id], email: @mailbox_new.email, refresh_token: jwt_response['refreshJwt'], uri: 'http://localhost:3000/verify')

        puts 'verifying  magiclink token again after email update...'
        magiclink_update_response = @mailmock.wait_for_email
        token = magiclink_update_response.text.match(/^http.+verify\?t=(.+)/)[1]

        magiclink_verify_post_update_response = @client.magiclink_verify_token(token)

        puts 'verifying email was updated...'
        my_details = @client.me(magiclink_verify_post_update_response['refreshJwt'])
        expect(my_details['email']).to eq(@mailbox_new.email)
        puts 'Magiclink Token Verified!'
      rescue StandardError => e
        raise StandardError "Verification failed - Could not verify token: #{e.message}"
      end.to_not raise_error
    end
  end
end
