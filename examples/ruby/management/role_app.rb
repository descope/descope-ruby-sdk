#!/usr/bin/env ruby
# frozen_string_literal: true

require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

name = 'My Role'

begin
  @logger.info('Going to create a new role')
  @client.create_role(
    name:, description: 'Allowed to test :)', permission_names: ['SSO Admin']
  )
rescue Descope::AuthException => e
  @logger.info("Role creation failed #{e}")
end

begin
  @logger.info('Loading all roles')
  roles_resp = @client.load_all_roles
  roles = roles_resp['roles']
  roles.each do |role|
    @logger.info("Search Found role #{role}")
  end

rescue Descope::AuthException => e
  @logger.error("Role load failed #{e}")
end

begin
  @logger.info('Updating newly created role')
  @client.update_role(
    name:,
    new_name: 'My Updated Role',
    description: 'New Description',
    permission_names: ['User Admin']
  )

rescue Descope::AuthException => e
  @logger.error("Role update failed #{e}")
end

begin
  @logger.info('Deleting newly created role')
  @client.delete_role('My Updated Role')

rescue Descope::AuthException => e
  @logger.error("Role deletion failed #{e}")
end

