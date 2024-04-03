#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../version_check'
require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

@tenant_id = ''

begin
  @logger.info('Going to create a new tenant')
  resp = @client.create_tenant(name: 'My First Tenant')
  @tenant_id = resp['id']
  @logger.info("Tenant creation response: #{resp}")
rescue Descope::AuthException => e
  @logger.info("Tenant creation failed #{e}")
end

begin
  @logger.info('Loading tenant by id')
  tenant_resp = @client.load_tenant(@tenant_id)
  @logger.info("Found tenant #{tenant_resp}")
rescue Descope::AuthException => e
  @logger.info("Permission load failed #{e}")
end

begin
  @logger.info('Loading all tenants')
  tenants_resp = @client.load_all_tenants
  tenants = tenants_resp['tenants']
  tenants.each do |tenant|
    @logger.info("Search Found tenant #{tenant}")
  end
rescue Descope::AuthException => e
  @logger.error("Permission load failed #{e}")
end

begin
  @logger.info('Updating newly created tenant')
  @client.update_tenant(
    name: 'My First Tenant', id: @tenant_id, self_provisioning_domains: ['mydomain.com']
  )
rescue Descope::AuthException => e
  @logger.error("Tenant update failed #{e}")
end

begin
  @logger.info('Deleting newly created tenant')
  @client.delete_tenant(@tenant_id)
rescue Descope::AuthException => e
  @logger.error("Tenant deletion failed #{e}")
end

