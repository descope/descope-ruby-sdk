#!/usr/bin/env ruby
# frozen_string_literal: true

require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

begin
  @logger.info('Going to create a new access key')
  access_key_resp = @client.create_access_key(name: 'key-name', expire_time: 1_677_844_931)
  access_key = access_key_resp['key']
  key_id = access_key['id']
  @logger.info("Create: created access key #{access_key}")
rescue Descope::AuthException => e
  @logger.info("Access key creation failed #{e}")
end

begin
  @logger.info('Searching for created access key')
  access_key_resp = @client.load_access_key(key_id)
  access_key = access_key_resp['key']
  @logger.info("Load: found access key #{access_key}")
rescue Descope::AuthException => e
  @logger.info("Access key load failed #{e}")
end

begin
  @logger.info('Searching all access keys')
  users_resp = @client.search_all_access_keys
  access_keys = users_resp['keys']
  access_keys.each do |key|
    @logger.info("Search Found access key #{key}")
  end
rescue Descope::AuthException => e
  @logger.info("Access key load failed #{e}")
end

begin
  @logger.info('Updating newly created access key')
  @client.update_access_key(id: key_id, name: 'New key name')
rescue Descope::AuthException => e
  @logger.info("Access key update failed #{e}")
end

begin
  @logger.info('Deactivating newly created access key')
  @client.deactivate_access_key(key_id)
rescue Descope::AuthException => e
  @logger.info("Access key deactivate failed #{e}")
end

begin
  @logger.info('Activating newly created access key')
  @client.activate_access_key(key_id)
rescue Descope::AuthException => e
  @logger.info("Access key activate failed #{e}")
end

begin
  @logger.info('Deleting newly created access key')
  @client.delete_access_key(key_id)
rescue Descope::AuthException => e
  @logger.info("Access key deletion failed #{e}")
end
