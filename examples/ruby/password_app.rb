#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './version_check'
require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

begin
  @logger.info('Going to signup using password...')
  puts 'Please insert email to signup with:\n'
  email = gets.chomp

  puts 'Please insert password to signup with:\n'
  password = gets.chomp

  jwt_response = @client.password_sign_up(login_id: email, password: password)
  @logger.info("Signup successful! jwt_response: #{jwt_response}")
  puts "=> #{Descope::Mixins::Common::SESSION_TOKEN_NAME}"
  session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
  refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')

  @logger.info('Validating email address...')
  @client.magiclink_update_user_email(login_id: email, email: email, refresh_token: refresh_token)

  puts "Validation email send, please paste the token you received by email:\n"
  token = gets.chomp
  jwt_response = @client.magiclink_verify_token(token)
  @logger.info("Token verified successfully! #{jwt_response}")
  session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
  refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')

  @logger.info('Going to reset password...')
  @client.password_reset(login_id: email)
  puts 'Reset password email send, please paste the token you received by email:\n'
  token = gets.chomp
  jwt_response = @client.magiclink_verify_token(token)
  @logger.info('Token verified successfully!')
  session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
  refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
  @logger.info("jwt_response: #{jwt_response}")

  puts "Please insert new password:\n"
  new_password = gets.chomp
  @client.password_update(login_id: email, new_password: new_password, refresh_token: refresh_token)
  @logger.info('Attempting to sign in with new password...')
  jwt_response = @client.password_sign_in(login_id: email, password: new_password)
  session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
  refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
  @logger.info("jwt_response: #{jwt_response}")

  @logger.info('going to validate session...')
  @client.validate_session(session_token: session_token)
  @logger.info('Session validated successfully and all is OK!')

  @logger.info('refreshing the session token...')
  claims = @client.refresh_session(refresh_token: refresh_token)
  @logger.info('going to revalidate the session with the newly refreshed token...')

  new_session_token = claims[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
  @client.validate_and_refresh_session(session_token: new_session_token, refresh_token: refresh_token)
  @logger.info('Session is also valid for the refreshed token.')

  @logger.info('going to sign out...')
  @client.sign_out(refresh_token)
  @logger.info('Session is signed out successfully.')

rescue Descope::AuthException => e
  @logger.error("Error: #{e.message}")
end
