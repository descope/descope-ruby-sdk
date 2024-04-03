#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './version_check'
require 'descope'

# include Descope::Mixin::Common
@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

@logger.info('Going to signup / signin using Magic Link ...')
print "Please insert email to signup / signin:\n"
email = gets.chomp
masked_mail = @client.magiclink_sign_up_or_in(
  method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
  login_id: email,
  uri: 'http://test.me'
)

print "Please insert the token you received by email (#{masked_mail}):\n"
token = gets.chomp
begin
  jwt_response = @client.magiclink_verify_token(token)
  @logger.info('Token is valid')
  refresh_token = jwt_response['refreshJwt']
  @logger.info("jwt_response: #{jwt_response}")
rescue Descope::AuthException => e
  @logger.error("Invalid Token #{e}")
  raise
end

begin
  @logger.info('Going to logout after sign-in / sign-up')
  @client.sign_out(refresh_token)
  @logger.info('User logged out after sign-in / sign-up')
rescue Descope::AuthException => e
  @logger.info("Failed to logged after sign-in / sign-up, err: #{e}")
end

@logger.info('Going to sign in same user again...')
@client.magiclink_sign_in(
  method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: email, uri: 'http://test.me'
)

print "Please insert the Token you received by email:\n"
token = gets.chomp
begin
  jwt_response = @client.magiclink_verify_token(token)
  @logger.info('Token is valid')
  session_token_1 = jwt_response['sessionJwt']
  refresh_token_1 = jwt_response['refreshJwt']
  @logger.info("jwt_response: #{jwt_response}")
rescue Descope::AuthException => e
  @logger.error("Invalid Token #{e}")
  raise
end

begin
  @logger.info("going to validate session...#{session_token_1}")
  @client.validate_and_refresh_session(
    session_token: session_token_1, refresh_token: refresh_token_1
  )
  @logger.info('Session is valid and all is OK')
rescue Descope::AuthException => e
  @logger.error("Session is not valid #{e}")
end

begin
  @logger.info(
    "Going to logout at the second time\nrefresh_token: #{refresh_token_1}"
  )
  @client.sign_out(refresh_token_1)
  @logger.info('User logged out')
rescue Descope::AuthException => e
  @logger.error("Failed to logged out user, err: #{e}")
end
