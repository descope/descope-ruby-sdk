# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::OTP do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
    include Mailmock
    @mailmock = Mailmock::Mail.new
  end

  after(:all) do
    puts 'Cleaning up test users...'
    all_users = @client.search_all_users
    all_users['users'].each do |user|
      if user['middleName'] == 'Ruby SDK User'
        puts "Deleting ruby spec test user #{user['loginIds'][0]}"
        @client.delete_user(user['loginIds'][0])
      end
    end
  end

  context 'test otp methods' do
    it 'should sign up with otp' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.otp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], user:)
      mail_response = @mailmock.wait_for_email
      code = mail_response.text.match(/(^\d{6}) is your authentication code./)[1]
      @client.otp_verify_code(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], code:)
    end

    it 'should sign in with otp' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.create_user(**user)
      @client.otp_sign_in(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id])
      mail_response = @mailmock.wait_for_email
      code = mail_response.text.match(/(^\d{6}) is your authentication code./)[1]
      @client.otp_verify_code(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], code:)
    end

    it 'should sign up or in with otp' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.create_user(**user)
      @client.otp_sign_up_or_in(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id])
      mail_response = @mailmock.wait_for_email
      code = mail_response.text.match(/(^\d{6}) is your authentication code./)[1]
      @client.otp_verify_code(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], code:)
    end

    it 'should update email on otp' do
      # Create user
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.create_user(**user)

      # Sign in OTP
      @client.otp_sign_in(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id])
      mail_response = @mailmock.wait_for_email
      code = mail_response.text.match(/(^\d{6}) is your authentication code./)[1]
      login_res = @client.otp_verify_code(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], code:)
      refresh_token = login_res['refreshSessionToken']['jwt']


      # Update email OTP with refresh token
      @mailbox_new = @mailmock.create_mailbox(user[:login_id], 'aws')
      @client.otp_update_user_email(login_id: user[:login_id], email: @mailbox_new.email, refresh_token:)
      otp_update_response = @mailmock.wait_for_email
      code = otp_update_response.text.match(/(^\d{6}) is your authentication code./)[1]
      @client.otp_verify_code(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user[:login_id], code:)

      # verify email updated
      my_details = @client.me(refresh_token)
      expect(my_details['email']).to eq(@mailbox_new.email)
    end
  end
end
