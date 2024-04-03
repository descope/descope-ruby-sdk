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
  @logger.info('Going to search audit')
  text = nil
  text = ARGV[0] if ARGV.length > 1
  from_ts = nil
  from_ts = DateTime.iso8601(ARGV[1]) if ARGV.length > 2
  res = @client.audit_search(text: text, from_ts: from_ts)
  @logger.info("Audit search result: #{res}")
rescue Descope::AuthException => e
  @logger.error("Audit search failed #{e}")
end
