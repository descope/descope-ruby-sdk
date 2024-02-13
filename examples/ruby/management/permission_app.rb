#!/usr/bin/env ruby
# frozen_string_literal: true

require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

begin
  @logger.info('Going to create a new permission')
  name = 'My Permission'
  @client.create_permission(name:, description: 'Allowed to test')

rescue Descope::AuthException => e
  @logger.info("Permission creation failed #{e}")
end

begin
  @logger.info('Loading all permissions')
  permissions_resp = @client.load_all_permissions
  permissions = permissions_resp['permissions']
  permissions.each do |permission|
    @logger.info("Search Found permission #{permission}")
  end

rescue Descope::AuthException => e
  @logger.error("Permission load failed #{e}")
end

begin
  @logger.info('Updating newly created permission')
  # update overrides all fields, must provide the entire entity
  # we mean to update.
  name = 'My Permission'
  @client.update_permission(
    name:, new_name: 'My Updated Permission', description: 'New Description'
  )

rescue Descope::AuthException => e
  @logger.error("Permission update failed #{e}")
end

begin
  @logger.info('Deleting newly created permission')
  @client.delete_permission('My Updated Permission')

rescue Descope::AuthException => e
  @logger.error("Permission deletion failed #{e}")
end

