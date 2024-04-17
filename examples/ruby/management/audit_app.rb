#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../version_check'
require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

begin
  @logger.info('Do you want to to create a new audit event? [y/n] ')
  create_audit = gets.chomp
  if create_audit == 'y'
    @logger.info('Enter the action for the audit event: ')
    action = gets.chomp
    @logger.info('Enter the type for the audit event: [info/warn/error] ')
    type = gets.chomp
    @logger.info('Enter the actorId for the audit event: ')
    actor_id = gets.chomp
    @logger.info('Enter the tenantId for the audit event: ')
    tenant_id = gets.chomp
    res = @client.audit_create_event(
      action: action,
      type: type,
      actor_id: actor_id,
      tenant_id: tenant_id
    )
    @logger.info("Audit event created successfully: #{res}")
  end

  @logger.info('Do you want to search the audit trail? [y/n] ')
  search_audit = gets.chomp
  if search_audit == 'y'
    @logger.info('Enter the text to search: ')
    text = gets.chomp
    @logger.info('Enter the from_ts in ISO8601 format (2024-01-01 15:00:00.000) to search: ')
    from_ts = gets.chomp
    res = @client.audit_search(text: text, from_ts: from_ts)
    @logger.info("Audit search result: #{res}")
  end
rescue Descope::AuthException => e
  @logger.error("Audit action failed #{e}")
end
