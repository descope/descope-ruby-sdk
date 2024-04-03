#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../version_check'
require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

user_login_id = 'des@copeland.com'

begin
  @logger.info('Going to create a new user')
  @client.create_user(login_id: user_login_id)
rescue Descope::AuthException => e
  @logger.info("User creation failed #{e}")
end

begin
  @logger.info('Searching for created user')
  user_resp = @client.load_user(user_login_id)
  user_res = user_resp['user']
  @logger.info("Load: found user #{user_res}")
rescue Descope::AuthException => e
  @logger.info("User load failed #{e}")
end

begin
  @logger.info('Searching all users created user')
  users_resp = @client.search_all_users
  users = users_resp['users']
  users.each do |user|
    @logger.info("Search Found user #{user}")
  end
rescue Descope::AuthException => e
  @logger.info("User load failed #{e}")
end

begin
  @logger.info('Updating newly created user')
  # update overrides all fields, must provide the entire entity
  # we mean to update.
  @client.update_user(
    login_id: user_login_id, name: 'Desmond Copeland'
  )
rescue Descope::AuthException => e
  @logger.info("User update failed #{e}")
end

begin
  @logger.info('Deleting newly created user')
  @client.delete_user(user_login_id)
rescue Descope::AuthException => e
  @logger.info("User deletion failed #{e}")
end
