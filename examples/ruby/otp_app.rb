#!/usr/bin/env ruby
# frozen_string_literal: true

require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']
@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })
@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@client.base_uri}")

begin
  @logger.info('Going to signup or in using OTP...')

  puts "Please select OTP method: [email, sms, voice]:\n"
  method = gets.chomp

  case method
  when 'email'
    requested_method = Descope::Mixins::Common::DeliveryMethod::EMAIL
    puts "Please insert the email address you want to use:\n"
    email = gets.chomp
    requested_params = { login_id: email }
  when 'sms'
    requested_method = Descope::Mixins::Common::DeliveryMethod::SMS
    @logger.info('Once signed up, we will use the update phone number')
    puts "Please insert the phone number you want to use:\n"
    phone = gets.chomp
    requested_params = { login_id: phone }
  when 'voice'
    requested_method = Descope::Mixins::Common::DeliveryMethod::VOICE
    @logger.info('Once signed up, we will use the update phone number')
    puts "Please insert the phone number you want to use:\n"
    phone = gets.chomp
    requested_params = { login_id: phone }
  else
    raise 'Invalid method'
  end

  @logger.info("Signing up using OTP with #{method}...")
  if method == 'email'
    user = { login_id: email, name: 'John Doe', email: email, phone: phone }
    login_id = email
    masked_method = @client.otp_sign_up(method: requested_method, user: user, login_id: email, phone: phone)
  else
    login_id = phone
    masked_method = @client.otp_sign_up_or_in(method: requested_method, login_id: phone)
  end

  puts "Please insert the code you received by #{method} to #{masked_method}:\n"
  value = gets.chomp

  jwt_response = @client.otp_verify_code(method: requested_method, login_id: login_id, code: value)
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
