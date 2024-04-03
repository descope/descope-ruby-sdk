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
  puts "Please select OTP method (email, sms, whatsapp, voice):\n"
  method = gets.chomp

  @logger.info("Going to signup or in using OTP using #{method}...")

  case method
  when 'email'
    requested_method = Descope::Mixins::Common::DeliveryMethod::EMAIL
  when 'sms'
    requested_method = Descope::Mixins::Common::DeliveryMethod::SMS
  when 'whatsapp'
    requested_method = Descope::Mixins::Common::DeliveryMethod::WHATSAPP
  when 'voice'
    requested_method = Descope::Mixins::Common::DeliveryMethod::VOICE
  else
    raise 'Invalid method'
  end
  masked = @client.otp_sign_up_or_in(method: requested_method, login_id: email)

  puts "Please insert the code you received by #{method} to #{masked}:\n"
  value = gets.chomp

  jwt_response = @client.otp_verify_code(method: requested_method, login_id: email, code: value)
  @logger.info('Code is valid')
  puts "jwt_response: #{jwt_response}"
  session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
  refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
  @logger.info("jwt_response: #{jwt_response}")

  @logger.info('going to validate session..')
  @client.validate_session(session_token: session_token)
  @logger.info('Session is valid and all is OK')

  @logger.info('refreshing the session token..')
  claims = @client.refresh_session(refresh_token: refresh_token)
  @logger.info(
    'going to revalidate the session with the newly refreshed token..'
  )

  new_session_token = claims.fetch(Descope::Mixins::Common::SESSION_TOKEN_NAME).fetch('jwt')
  @client.validate_and_refresh_session(session_token: new_session_token, refresh_token: refresh_token)
  @logger.info('Session is valid also for the refreshed token.')
rescue Descope::AuthException => e
  @logger.error("Error: #{e.message}")
end
