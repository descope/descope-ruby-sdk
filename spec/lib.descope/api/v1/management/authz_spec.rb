# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Authz do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Authz)
    @instance = dummy_instance
  end

  context '.save_schema' do
    it 'should respond to .save_schema' do
      expect(@instance).to respond_to :save_schema
    end

    it 'is expected to create or update ReBac schema' do
      schema = {
        name: 'name-of-schema',
        namespaces: [
          {
            name: 'name-of-namespace',
            relationDefinitions: [
              {
                name: 'name-of-relation-definition',
                complexDefinition: {
                  nType: 'child',
                  expression: {
                    neType: 'self'
                  }
                }
              }
            ]
          }
        ]
      }
      expect(@instance).to receive(:post).with(
        AUTHZ_SCHEMA_SAVE,
        {
          schema: schema,
          upgrade: true
        }
      )
      expect do
        @instance.save_schema(schema: schema, upgrade: true)
      end.not_to raise_error
    end
  end

  context '.delete_schema' do
    it 'should respond to .delete_schema' do
      expect(@instance).to respond_to :delete_schema
    end

    it 'is expected to delete the schema for the project which will also delete all relations' do
      expect(@instance).to receive(:post).with(AUTHZ_SCHEMA_DELETE)
      expect do
        @instance.delete_schema
      end.not_to raise_error
    end
  end

  context '.load_schema' do
    it 'should respond to .load_schema' do
      expect(@instance).to respond_to :load_schema
    end

    it 'is expected to load the schema for the project' do
      expect(@instance).to receive(:post).with(AUTHZ_SCHEMA_LOAD)
      expect do
        @instance.load_schema
      end.not_to raise_error
    end
  end

  context '.save_namespace' do
    it 'should respond to .save_namespace' do
      expect(@instance).to respond_to :save_namespace
    end

    it 'is expected to create or update the given namespace' do
      expect(@instance).to receive(:post).with(
        AUTHZ_NS_SAVE,
        {
          namespace: 'test-namespace',
          oldName: 'old-namespace',
          schemaName: 'schema-name'
        }
      )
      expect do
        @instance.save_namespace(namespace: 'test-namespace', old_name: 'old-namespace', schema_name: 'schema-name')
      end.not_to raise_error
    end
  end

  context '.delete_namespace' do
    it 'should respond to .delete_namespace' do
      expect(@instance).to respond_to :delete_namespace
    end

    it 'is expected to delete the given namespace' do
      expect(@instance).to receive(:post).with(
        AUTHZ_NS_DELETE,
        {
          name: 'test-namespace',
          schemaName: 'schema-name'
        }
      )
      expect do
        @instance.delete_namespace(name: 'test-namespace', schema_name: 'schema-name')
      end.not_to raise_error
    end
  end

  context '.save_relation_definition' do
    it 'should respond to .save_relation_definition' do
      expect(@instance).to respond_to :save_relation_definition
    end

    it 'is expected to create or update the given relation definition' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RD_SAVE,
        {
          relationDefinition: 'test-relation-definition',
          namespaceName: 'test-namespace',
          old_name: 'old-relation-definition',
          schemaName: 'schema-name'
        }
      )
      expect do
        @instance.save_relation_definition(
          relation_definition: 'test-relation-definition',
          namespace_name: 'test-namespace',
          old_name: 'old-relation-definition',
          schema_name: 'schema-name'
        )
      end.not_to raise_error
    end
  end

  context '.delete_relation_definition' do
    it 'should respond to .delete_relation_definition' do
      expect(@instance).to respond_to :delete_relation_definition
    end

    it 'is expected to delete the given relation definition' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RD_DELETE,
        {
          name: 'test-relation-definition',
          namespace: 'test-namespace',
          schemaName: 'schema-name'
        }
      )
      expect do
        @instance.delete_relation_definition(
          name: 'test-relation-definition',
          namespace: 'test-namespace',
          schema_name: 'schema-name'
        )
      end.not_to raise_error
    end
  end

  context '.create_relation' do
    it 'should respond to .create_relation' do
      expect(@instance).to respond_to :create_relation
    end

    it 'is expected to create the given relation' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_CREATE,
        {
          relations: 'test-relations'
        }
      )
      expect do
        @instance.create_relation(relations: 'test-relations')
      end.not_to raise_error
    end
  end

  context '.delete_relation' do
    it 'should respond to .delete_relation' do
      expect(@instance).to respond_to :delete_relation
    end

    it 'is expected to delete the given relation' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_DELETE,
        {
          relations: 'test-relations'
        }
      )
      expect do
        @instance.delete_relation(relations: 'test-relations')
      end.not_to raise_error
    end
  end

  context '.delete_relations_for_resources' do
    it 'should respond to .delete_relations_for_resources' do
      expect(@instance).to respond_to :delete_relations_for_resources
    end

    it 'is expected to delete the given relations for resources' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_DELETE_RESOURCES,
        {
          resources: 'test-resources'
        }
      )
      expect do
        @instance.delete_relations_for_resources(resources: 'test-resources')
      end.not_to raise_error
    end
  end

  context 'has_relations?' do
    it 'should respond to .has_relations?' do
      expect(@instance).to respond_to :has_relations?
    end

    it 'is expected to return true if the given resource has relations' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_HAS_RELATIONS,
        {
          relationQueries: ['some-query']
        }
      )
      expect do
        @instance.has_relations?(relation_queries: ['some-query'])
      end.not_to raise_error
    end
  end

  context 'who_can_access?' do
    it 'should respond to .who_can_access?' do
      expect(@instance).to respond_to :who_can_access?
    end

    it 'is expected to return the list of targets who can access the given resource with the given RD' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_WHO,
        {
          resource: 'test-resource',
          relationDefinition: 'test-relation-definition',
          namespace: 'test-namespace'
        }
      )
      expect do
        @instance.who_can_access?(resource: 'test-resource', relation_definition: 'test-relation-definition',
                                  namespace: 'test-namespace')
      end.not_to raise_error
    end
  end

  context 'resource_relations' do
    it 'should respond to .resource_relations' do
      expect(@instance).to respond_to :resource_relations
    end

    it 'is expected to return the list of relations for the given resources' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_RESOURCE,
        {
          resources: ['test-resources']
        }
      )
      expect do
        @instance.resource_relations(resources: ['test-resources'])
      end.not_to raise_error
    end
  end

  context 'target_relations' do
    it 'should respond to .target_relations' do
      expect(@instance).to respond_to :target_relations
    end

    it 'is expected to return the list of relations for the given targets' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_TARGETS,
        {
          targets: ['test-targets']
        }
      )
      expect do
        @instance.target_relations(targets: ['test-targets'])
      end.not_to raise_error
    end
  end

  context 'what_can_target_access?' do
    let(:mock_response) do
      {
        'relations' => [
          {
            'relationDefinition' => 'test-relation-definition',
            'namespace' => 'test-namespace',
            'targets' => ['test-targets'],
            'resources' => ['test-resources']
          }
        ]
      }
    end

    before do
      allow(@instance).to receive(:post).with(
        AUTHZ_RE_TARGET_ALL,
        {
          target: 'test-target'
        }
      ).and_return(mock_response)
    end

    it 'should respond to .what_can_target_access?' do
      expect(@instance).to respond_to :what_can_target_access?
    end

    it 'is expected to return the list of relations for the given target' do
      expect(@instance).to receive(:post).with(
        AUTHZ_RE_TARGET_ALL,
        {
          target: 'test-target'
        }
      )
      res = nil
      expect do
        res = @instance.what_can_target_access?(target: 'test-target')
      end.not_to raise_error
      expect(res).to be_a(Array)
      expect(res.size).to eq(1)
    end
  end
end
