# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Authz do
  before(:all) do
    raise 'DESCOPE_MANAGEMENT_KEY is not set' if ENV['DESCOPE_MANAGEMENT_KEY'].nil?

    @client = DescopeClient.new(Configuration.config)
    puts 'authz schema delete'
  end

  context 'authz ops' do
    before(:all) do
      # Instead of deleting the entire schema, we'll work with it
      # This allows parallel test execution
      # Only delete schema if we're running in isolation
      if ENV['AUTHZ_FULL_TEST'] == 'true'
        @client.authz_delete_schema
      end
    end

    it 'should create a new schema' do
      puts 'Creating the ReBAC schema...'
      schema = {
        name: '1.0',
        namespaces: [
          {
            name: 'group',
            relationDefinitions: [
              {
                name: 'member'
              },
              {
                name: 'owner'
              }
            ]
          },
          {
            name: 'note',
            relationDefinitions: [
              {
                name: 'owner'
              },
              {
                name: 'editor',
                complexDefinition: {
                  nType: 'union',
                  children: [
                    {
                      nType: 'child',
                      expression: {
                        neType: 'self'
                      }
                    },
                    {
                      nType: 'child',
                      expression: {
                        neType: 'targetSet',
                        targetRelationDefinition: 'owner',
                        targetRelationDefinitionNamespace: 'note'
                      }
                    }
                  ]
                }
              },
              {
                name: 'viewer',
                complexDefinition: {
                  nType: 'union',
                  children: [
                    {
                      nType: 'child',
                      expression: {
                        neType: 'self'
                      }
                    },
                    {
                      nType: 'child',
                      expression: {
                        neType: 'targetSet',
                        targetRelationDefinition: 'editor',
                        targetRelationDefinitionNamespace: 'note'
                      }
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
      @client.authz_save_schema(schema:, upgrade: true)
    end

    it 'should create relation definition' do
      @client.authz_save_relation_definition(
        relation_definition: {
          name: 'owner'
        },
        namespace: 'group'
      )
      @client.authz_save_relation_definition(
        relation_definition: {
          name: 'member'
        },
        namespace: 'group'
      )
      @client.authz_save_relation_definition(
        relation_definition: {
          name: 'owner'
        },
        namespace: 'note'
      )
      @client.authz_save_relation_definition(
        relation_definition: {
          name: 'editor',
          complexDefinition: {
            nType: 'union',
            children: [
              {
                nType: 'child',
                expression: {
                  neType: 'self'
                }
              },
              {
                nType: 'child',
                expression: {
                  neType: 'targetSet',
                  targetRelationDefinition: 'owner',
                  targetRelationDefinitionNamespace: 'note'
                }
              }
            ]
          }
        },
        namespace: 'note'
      )
      @client.authz_save_relation_definition(
        relation_definition: {
          name: 'viewer',
          complexDefinition: {
            nType: 'union',
            children: [
              {
                nType: 'child',
                expression: {
                  neType: 'self'
                }
              },
              {
                nType: 'child',
                expression: {
                  neType: 'targetSet',
                  targetRelationDefinition: 'editor',
                  targetRelationDefinitionNamespace: 'note'
                }
              }
            ]
          }
        },
        namespace: 'note'
      )
    end

    it 'should create a relation between a resource and user' do
      # Use unique resource name to avoid conflicts between parallel tests
      unique_resource = "#{SpecUtils.build_prefix}some-doc"
      unique_user = "#{SpecUtils.build_prefix}user1"
      
      @client.authz_create_relations(
        [
          {
            "resource": unique_resource,
            "relationDefinition": 'owner',
            "namespace": 'note',
            "target": unique_user
          }
        ]
      )

      # Check if target has the relevant relation
      # The answer should be true because an owner is also a viewer
      relations = @client.authz_has_relations?(
        [
          {
            "resource": unique_resource,
            "relationDefinition": 'viewer',
            "namespace": 'note',
            "target": unique_user
          }
        ]
      )
      expect(relations['relationQueries'][0]['hasRelation']).to be_truthy
      
      # Clean up the test relations
      @client.authz_delete_relations(
        [
          {
            "resource": unique_resource,
            "relationDefinition": 'owner',
            "namespace": 'note',
            "target": unique_user
          }
        ]
      )
    end
  end
end
