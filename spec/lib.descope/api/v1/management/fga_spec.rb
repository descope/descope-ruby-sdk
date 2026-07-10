# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::FGA do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::FGA)
    @instance = dummy_instance
  end

  context '.fga_save_schema' do
    it 'should respond to .fga_save_schema' do
      expect(@instance).to respond_to :fga_save_schema
    end

    it 'is expected to save the FGA schema' do
      schema = 'model AuthZ 1.0\ntype user\ntype doc\n  relation owner: user'
      expect(@instance).to receive(:post).with(
        FGA_SAVE_SCHEMA_PATH,
        { dsl: schema }
      )
      expect do
        @instance.fga_save_schema(schema: schema)
      end.not_to raise_error
    end
  end

  context '.fga_load_schema' do
    it 'should respond to .fga_load_schema' do
      expect(@instance).to respond_to :fga_load_schema
    end

    it 'is expected to load the FGA schema' do
      expect(@instance).to receive(:get).with(FGA_LOAD_SCHEMA_PATH)
      expect do
        @instance.fga_load_schema
      end.not_to raise_error
    end
  end

  context '.fga_create_relations' do
    it 'should respond to .fga_create_relations' do
      expect(@instance).to respond_to :fga_create_relations
    end

    it 'is expected to create the given relations' do
      tuples = [{ resource: 'doc1', relation: 'owner', target: 'user1' }]
      expect(@instance).to receive(:post).with(
        FGA_CREATE_RELATIONS_PATH,
        { tuples: tuples }
      )
      expect do
        @instance.fga_create_relations(tuples: tuples)
      end.not_to raise_error
    end
  end

  context '.fga_delete_relations' do
    it 'should respond to .fga_delete_relations' do
      expect(@instance).to respond_to :fga_delete_relations
    end

    it 'is expected to delete the given relations' do
      tuples = [{ resource: 'doc1', relation: 'owner', target: 'user1' }]
      expect(@instance).to receive(:post).with(
        FGA_DELETE_RELATIONS_PATH,
        { tuples: tuples }
      )
      expect do
        @instance.fga_delete_relations(tuples: tuples)
      end.not_to raise_error
    end
  end

  context '.fga_check' do
    it 'should respond to .fga_check' do
      expect(@instance).to respond_to :fga_check
    end

    it 'is expected to check the given relations' do
      tuples = [{ resource: 'doc1', relation: 'owner', target: 'user1' }]
      expect(@instance).to receive(:post).with(
        FGA_CHECK_PATH,
        { tuples: tuples }
      )
      expect do
        @instance.fga_check(tuples: tuples)
      end.not_to raise_error
    end
  end

  context '.fga_load_mappable_schema' do
    it 'should respond to .fga_load_mappable_schema' do
      expect(@instance).to respond_to :fga_load_mappable_schema
    end

    it 'is expected to load the mappable schema for the given tenant' do
      expect(@instance).to receive(:get).with(
        FGA_LOAD_MAPPABLE_SCHEMA_PATH,
        { tenantId: 'tenant-1' }
      )
      expect do
        @instance.fga_load_mappable_schema(tenant_id: 'tenant-1')
      end.not_to raise_error
    end

    it 'is expected to include resourcesLimit when options are given' do
      expect(@instance).to receive(:get).with(
        FGA_LOAD_MAPPABLE_SCHEMA_PATH,
        { tenantId: 'tenant-1', resourcesLimit: 10 }
      )
      expect do
        @instance.fga_load_mappable_schema(tenant_id: 'tenant-1', options: { resourcesLimit: 10 })
      end.not_to raise_error
    end
  end

  context '.fga_search_mappable_resources' do
    it 'should respond to .fga_search_mappable_resources' do
      expect(@instance).to respond_to :fga_search_mappable_resources
    end

    it 'is expected to search for mappable resources for the given tenant' do
      resources_queries = [{ resourceType: 'doc' }]
      expect(@instance).to receive(:post).with(
        FGA_SEARCH_MAPPABLE_RESOURCES_PATH,
        { tenantId: 'tenant-1', resourcesQueries: resources_queries }
      )
      expect do
        @instance.fga_search_mappable_resources(tenant_id: 'tenant-1', resources_queries: resources_queries)
      end.not_to raise_error
    end
  end

  context '.fga_load_resources_details' do
    it 'should respond to .fga_load_resources_details' do
      expect(@instance).to respond_to :fga_load_resources_details
    end

    it 'is expected to load the details of the given resource identifiers' do
      resource_identifiers = [{ resourceId: 'doc1', resourceType: 'doc' }]
      expect(@instance).to receive(:post).with(
        FGA_RESOURCES_LOAD_PATH,
        { resourceIdentifiers: resource_identifiers }
      )
      expect do
        @instance.fga_load_resources_details(resource_identifiers: resource_identifiers)
      end.not_to raise_error
    end
  end

  context '.fga_save_resources_details' do
    it 'should respond to .fga_save_resources_details' do
      expect(@instance).to respond_to :fga_save_resources_details
    end

    it 'is expected to save the details of the given resources' do
      resources_details = [{ resourceId: 'doc1', resourceType: 'doc', displayName: 'Document 1' }]
      expect(@instance).to receive(:post).with(
        FGA_RESOURCES_SAVE_PATH,
        { resourcesDetails: resources_details }
      )
      expect do
        @instance.fga_save_resources_details(resources_details: resources_details)
      end.not_to raise_error
    end
  end
end
