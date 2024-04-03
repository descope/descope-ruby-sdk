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
  @logger.info('Creating test authz schema if different name')
  schema = @client.authz_load_schema
  File.open('./authz_files.json', 'rt') do |f|
    schema_from_file = JSON.parse(f.read)
    if schema['name'] != schema_from_file['name']
      @logger.info('Schema is different, upgrading...')
      @client.authz_save_schema(schema: schema_from_file, upgrade: true)
      @client.authz_create_relations(
        [
          {
            "resource": 'Dev',
            "relationDefinition": 'parent',
            "namespace": 'org',
            "target": 'Descope'
          },
          {
            "resource": 'Sales',
            "relationDefinition": 'parent',
            "namespace": 'org',
            "target": 'Descope'
          },
          {
            "resource": 'Dev',
            "relationDefinition": 'member',
            "namespace": 'org',
            "target": 'u1'
          },
          {
            "resource": 'Dev',
            "relationDefinition": 'member',
            "namespace": 'org',
            "target": 'u3'
          },
          {
            "resource": 'Sales',
            "relationDefinition": 'member',
            "namespace": 'org',
            "target": 'u2'
          },
          {
            "resource": 'Presentations',
            "relationDefinition": 'parent',
            "namespace": 'folder',
            "target": 'Internal'
          },
          {
            "resource": 'roadmap.ppt',
            "relationDefinition": 'parent',
            "namespace": 'doc',
            "target": 'Presentations'
          },
          {
            "resource": 'roadmap.ppt',
            "relationDefinition": 'owner',
            "namespace": 'doc',
            "target": 'u1'
          },
          {
            "resource": 'Internal',
            "relationDefinition": 'viewer',
            "namespace": 'folder',
            "targetSetResource": 'Descope',
            "targetSetRelationDefinition": 'member',
            "targetSetRelationDefinitionNamespace": 'org'
          },
          {
            "resource": 'Presentations',
            "relationDefinition": 'editor',
            "namespace": 'folder',
            "targetSetResource": 'Sales',
            "targetSetRelationDefinition": 'member',
            "targetSetRelationDefinitionNamespace": 'org'
          }
        ]
      )
    end

    res = @client.authz_has_relations?([
                                         {
                                           "resource": 'roadmap.ppt',
                                           "relationDefinition": 'owner',
                                           "namespace": 'doc',
                                           "target": 'u1'
                                         },
                                         {
                                           "resource": 'roadmap.ppt',
                                           "relationDefinition": 'editor',
                                           "namespace": 'doc',
                                           "target": 'u1'
                                         },
                                         {
                                           "resource": 'roadmap.ppt',
                                           "relationDefinition": 'viewer',
                                           "namespace": 'doc',
                                           "target": 'u1'
                                         },
                                         {
                                           "resource": 'roadmap.ppt',
                                           "relationDefinition": 'viewer',
                                           "namespace": 'doc',
                                           "target": 'u3'
                                         },
                                         {
                                           "resource": 'roadmap.ppt',
                                           "relationDefinition": 'editor',
                                           "namespace": 'doc',
                                           "target": 'u3'
                                         },
                                         {
                                           "resource": 'roadmap.ppt',
                                           "relationDefinition": 'editor',
                                           "namespace": 'doc',
                                           "target": 'u2'
                                         }
                                       ])
    @logger.info("Checking existing relations: #{res}")
  rescue Descope::AuthException => e
    @logger.error("Audit search failed #{e}")
  end
end
