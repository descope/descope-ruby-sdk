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
  name = 'sign-up-or-in'

  begin
    @logger.info("Going to export 'sign-up-or-in' flow")
    @res = @client.export_flow(name)

  rescue Descope::AuthException => e
    @logger.error("Export flow failed #{e}")
  end

  begin
    @logger.info('Importing sign-up-or-in flow and change name')
    @res['flow']['name'] = 'Importing from SDK'
    @client.import_flow(
      flow_id: 'sign-up-or-in',
      flow: @res['flow'],
      screens: @res['screens']
    )
  rescue Descope::AuthException => e
    @logger.info("Importing flow failed #{e}")
  end

  begin
    @logger.info('Going to export the project theme')
    @res = @client.export_theme
    @logger.info("Export theme success: #{@res}")

  rescue Descope::AuthException => e
    @logger.info("Export theme failed #{e}")
  end

  begin
    @logger.info('Importing theme back')
    @client.import_theme(@res)
    @logger.info('Importing theme success')
  rescue Descope::AuthException => e
    @logger.error("Importing theme failed #{e}")
  end

rescue Descope::AuthException
  raise
end
