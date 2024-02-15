#!/usr/bin/env ruby
# frozen_string_literal: true

require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

begin
  @logger.info('Going to signup or in using OTP...')
  puts 'Please insert email to signup or in:\n'
  email = gets.chomp
  masked_email = @client.otp_sign_up_or_in(
    method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: email
  )

  puts "Please insert the code you received by email to #{masked_email}:\n"
  value = gets.chomp

  jwt_response = @client.otp_verify_code(
    method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: email, code: value
  )
  @logger.info('Code is valid')
  puts "jwt_response: #{jwt_response}"
  session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
  refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
  @logger.info("jwt_response: #{jwt_response}")

  @logger.info('going to validate session..')
  @client.validate_session(session_token:)
  @logger.info('Session is valid and all is OK')

  @logger.info('refreshing the session token..')
  claims = @client.refresh_session(refresh_token:)
  @logger.info(
    'going to revalidate the session with the newly refreshed token..'
  )

  new_session_token = claims.fetch(Descope::Mixins::Common::SESSION_TOKEN_NAME).fetch('jwt')
  @client.validate_and_refresh_session(session_token: new_session_token, refresh_token:)
  @logger.info('Session is valid also for the refreshed token.')
rescue Descope::AuthException => e
  @logger.error("Error: #{e.message}")
end
