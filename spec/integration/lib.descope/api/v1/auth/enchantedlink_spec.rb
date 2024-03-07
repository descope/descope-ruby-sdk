# frozen_string_literal: true

require 'spec_helper'

def poll_for_session(descope_client, pending_ref)
  max_tries = 15
  i = 0
  done = false
  while !done && i < max_tries
    begin
      i += 1
      @client.logger.info('waiting 4 seconds for session to be created...')
      sleep(4)
      print '.'
      @client.logger.info("Getting session for pending_ref: #{pending_ref}...")
      jwt_response = descope_client.enchanted_link_get_session(pending_ref)
      done = true
    rescue Descope::AuthException, Descope::Unauthorized => e
      @client.logger.info("Failed pending session, err: #{e}")
     nil
    end

    next unless jwt_response

    @client.logger.info("jwt_response: #{jwt_response}")
    refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME]['jwt']

    @client.logger.info("refresh_token: #{refresh_token}")
    done = true
    return refresh_token
  end
end

def verify_session(descope_client: nil, res: nil, user: nil)
  raise StandardError, 'Missing required parameters' if descope_client.nil? || res.nil? || user.nil?

  token = res['link'].match(/.+verify\?t=(.+)/)[1]
  @client.logger.info("token: #{token}")

  expect do
    descope_client.enchanted_link_verify_token(token)
    @client.logger.info('EnchantedLink Token Verified! now getting session information...')
    @client.logger.info('Polling for session...')
    refresh_token = poll_for_session(descope_client, res['pendingRef'])
    my_details = descope_client.me(refresh_token)
    expect(my_details['email']).to eq(user['email'])
    @client.logger.info('EnchantedLink Token Verified via sign in!')
  rescue StandardError => e
    raise StandardError, "Verification failed - Could not verify token #{e.message}"

  end.to_not raise_error
end

describe Descope::Api::V1::Auth::EnchantedLink do
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

  context 'test EnchantedLink for test user' do
    it 'should sign in with enchanted link' do
      user = build(:user)
      test_user = @client.create_test_user(**user)['user']
      @client.logger.info("Should sign in a test user => #{test_user['loginIds'][0]} with enchanted link...")
      res = @client.generate_enchanted_link_for_test_user(login_id: test_user['loginIds'][0], uri: 'http://localhost:3000/verify')
      @client.logger.info("res: #{res}")
      @client.logger.info('Verifying session...')
      verify_session(descope_client: @client, res:, user: test_user)
    end
  end
end
