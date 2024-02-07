# frozen_string_literal: true


require 'spec_helper'

def poll_for_session(descope_client, pending_ref)
  max_tries = 15
  i = 0
  done = false
  while !done && i < max_tries
    begin
      i += 1
      puts 'waiting 4 seconds for session to be created...'
      sleep(4)
      print '.'
      jwt_response = descope_client.enchanted_link_get_session(pending_ref)
      done = true
    rescue Descope::AuthException, Descope::Unauthorized => e
      puts "Failed pending session, err: #{e}"
      nil
    end

    next unless jwt_response
    puts "jwt_response: #{jwt_response}"
    refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME]['jwt']

    puts "refresh_token: #{refresh_token}"
    done = true
    return refresh_token
  end
end

def verify_session(descope_client: nil, res: nil, user: nil, update_email: nil, mailmock: nil)
  raise StandardError, 'Missing required parameters' if descope_client.nil? || res.nil? || user.nil? || mailmock.nil?

  puts "sent email to #{res['maskedEmail']}"
  link_id = res['linkId']
  pending_ref = res['pendingRef']
  puts "link_id: #{link_id}"

  mail_response = mailmock.wait_for_email
  extract_link = mail_response.text.match(/^#{link_id}\s->\s.+verify.+/)
  puts "extract_link: #{extract_link}"
  token = extract_link[0].match(/.+verify\?t=(.+)/)[1]
  puts "token: #{token}"

  expect do
    descope_client.enchanted_link_verify_token(token)
    puts 'EnchantedLink Token Verified! now getting session information...'
    puts 'Polling for session...'
    refresh_token = poll_for_session(descope_client, pending_ref)

    if update_email
      puts '1. UPDATE EMAIL FLOW'

      puts '2. Creating new mailbox...'
      @mailbox_new = mailmock.create_mailbox(user[:login_id], 'aws')

      puts "3. Updating email to #{@mailbox_new.email}..."
      enchantedlink_update_response = descope_client.enchanted_link_update_user_email(
        login_id: user[:login_id],
        email: @mailbox_new.email,
        refresh_token:,
        uri: 'http://localhost:3000/verify'
      )

      puts '4. Email updated! - Now verifying token after update...'
      mail_response = mailmock.wait_for_email

      extract_link = mail_response.text.match(/^#{enchantedlink_update_response['linkId']}\s->\s.+verify.+/)
      puts "5. new extract_link: #{extract_link}"

      new_token = extract_link[0].match(/.+verify\?t=(.+)/)[1]
      puts "new_token: #{new_token}"
      puts '6. Verifying new token..'
      descope_client.enchanted_link_verify_token(new_token)

      puts '7. Getting new session information after email update...'
      puts "8. enchantedlink_update_response: #{enchantedlink_update_response}"
      new_pending_ref = enchantedlink_update_response['pendingRef']
      refresh_token = poll_for_session(descope_client, new_pending_ref)
    end

    my_details = descope_client.me(refresh_token)

    if update_email
      puts "9. Verifying email updated to #{@mailbox_new.email}..."
      expect(my_details['email']).to eq(@mailbox_new.email)
    else
      expect(my_details['email']).to eq(user[:email])
    end
  rescue StandardError => e
    raise StandardError, "Verification failed - Could not verify token #{e.message}"

  end.to_not raise_error
end

describe Descope::Api::V1::Auth::EnchantedLink do
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

  context 'test EnchantedLink methods' do
    it 'should sign up with enchanted link' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      res = @client.enchanted_link_sign_up(login_id: user[:login_id], user:, uri: 'http://localhost:3000/verify')
      verify_session(descope_client: @client, res:, user:, update_email: false, mailmock: @mailmock)
    end

    it 'should sign in with enchantedlink' do
      user = build(:user)
      @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
      user[:email] = @mailbox.email
      @client.create_user(**user)
      res = @client.enchanted_link_sign_in(login_id: user[:login_id], uri: 'http://localhost:3000/verify')
      verify_session(descope_client: @client, res:, user:, update_email: false, mailmock: @mailmock)
    end
    #
    #
    # it 'should sign up or in with enchantedlink' do
    #   user = build(:user)
    #   @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
    #   user[:email] = @mailbox.email
    #   @client.create_user(**user)
    #   res = @client.enchanted_link_sign_up_or_in(login_id: user[:login_id], uri: 'http://localhost:3000/verify')
    #   verify_session(descope_client: @client, res:, user:, update_email: false, mailmock: @mailmock)
    # end
    #
    # it 'should update email on enchantedlink' do
    #   user = build(:user)
    #   @mailbox = @mailmock.create_mailbox(user[:login_id], 'aws')
    #   user[:email] = @mailbox.email
    #   puts "Creating user #{user[:email]}..."
    #   @client.create_user(**user)
    #
    #   # Sign in EnchantedLink
    #   puts "Signing in user #{user[:email]}..."
    #   res = @client.enchanted_link_sign_in(login_id: user[:login_id], uri: 'http://localhost:3000/verify')
    #   verify_session(descope_client: @client, res:, user:, update_email: true, mailmock: @mailmock)
    # end
  end
end
