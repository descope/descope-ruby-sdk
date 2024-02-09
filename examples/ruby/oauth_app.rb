#!/usr/bin/env ruby
# frozen_string_literal: true

require 'descope'
require 'launchy'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

begin
  @logger.info('Going to login with Oauth auth method ...')
  resp = @client.oauth_start(provider: 'github', return_url: 'https://www.google.com')
  @logger.info("oauth response: #{resp}")

  # open the browser with the url
  link = resp['redirectUrl']
  Launchy.open(link) # open the browser with the


  puts "Please insert the code you received from redirect URI:\n"
  code = gets.chomp

  jwt_response = @client.oauth_exchange_token(code)
  @logger.info('oauth code valid')
  refresh_token = jwt_response['refreshSessionToken']['jwt']
  @client.sign_out(refresh_token)
  @logger.info('User logged out')
rescue Descope::AuthException => e
  @logger.error("Error: #{e.message}")
end
