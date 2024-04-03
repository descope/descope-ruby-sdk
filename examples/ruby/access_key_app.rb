#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './version_check'
require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })
access_key = nil

begin
  @logger.info('Going to login by using access key ...')

  if access_key.nil?
    print "Insert access key here\n"
    access_key = gets.chomp
  end

  begin
    login_options = {
      customClaims: { "k1": 'v1' }
    }
    jwt_response = @client.exchange_access_key(access_key: access_key, login_options: login_options)
    @logger.info('exchange access key successfully')
    @logger.info("jwt_response: #{jwt_response}")

    permission_name = 'TestPermission'
    permission_presented = @client.validate_permissions(
      jwt_response: jwt_response, permissions: [permission_name]
    )
    @logger.info("#{permission_name} presented on the jwt: [#{permission_presented}]")
    role_name = 'TestRole'
    role_presented = @client.validate_roles(jwt_response: jwt_response, roles: [role_name])
    @logger.info("#{role_name} presented on the jwt: [#{role_presented}]")
  rescue Descope::AuthException => e
    @logger.error("Failed to exchange access key #{e}")
    raise
  end
rescue StandardError => e
  @logger.error("Failed to initialize DescopeClient #{e}")
  raise
end
