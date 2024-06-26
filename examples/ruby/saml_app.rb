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
  @logger.info('Going to login with SAML auth method')
  @logger.info('make sure to configure your SAML for the tenant you are going to use')
  @logger.info('https://docs.descope.com/tutorials/sso/')
  puts 'Enter tenant id:'
  tenant_id = gets.chomp
  @logger.info('CMD click the url and then copy the code from the browser')
  response = @client.saml_sign_in(tenant: tenant_id, redirect_url: 'https://www.google.com')
  @logger.info("SAML response: #{response}")

  puts 'Enter code:'
  code = gets.chomp
  @logger.info("Exchanging code: #{code}")
  jwt_response = @client.saml_exchange_token(code)
  refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')

  res = @client.me(refresh_token)
  @logger.info("Me response: #{res}")

  @logger.info('signing out...')
  @client.sign_out(refresh_token)
rescue Descope::AuthException => e
  @logger.error("Error: #{e.message}")
end
