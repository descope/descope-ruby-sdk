# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Tenant do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Tenant)
    @instance = dummy_instance
  end

  context '.create_tenant' do
    it 'should respond to .create_tenant' do
      expect(@instance).to respond_to :create_tenant
    end

    it 'is expected to create a new tenant' do
      expect(@instance).to receive(:post).with(
        TENANT_CREATE_PATH, {
          name: 'test',
          id: 'test',
          selfProvisioningDomains: %w[descope.com descope.io],
          customAttributes: [
            { name: 'test', value: 'test' },
            { name: 'test2', value: 'test2' }
          ]
        }
      )
      expect do
        @instance.create_tenant(
          name: 'test',
          id: 'test',
          self_provisioning_domains: %w[descope.com descope.io],
          custom_attributes: [
            { name: 'test', value: 'test' },
            { name: 'test2', value: 'test2' }
          ]
        )
      end.not_to raise_error
    end
  end

  context '.update_tenant' do
    it 'should respond to .update_tenant' do
      expect(@instance).to respond_to :update_tenant
    end

    it 'is expected to update a tenant' do
      expect(@instance).to receive(:post).with(
        TENANT_UPDATE_PATH, {
          name: 'test',
          id: 'test',
          selfProvisioningDomains: %w[descope.com descope.io],
          customAttributes: [
            { name: 'test', value: 'test' },
            { name: 'test2', value: 'test2' }
          ]
        }
      )
      expect do
        @instance.update_tenant(
          name: 'test',
          id: 'test',
          self_provisioning_domains: %w[descope.com descope.io],
          custom_attributes: [
            { name: 'test', value: 'test' },
            { name: 'test2', value: 'test2' }
          ]
        )
      end.not_to raise_error
    end
  end

  context '.delete_tenant' do
    it 'should respond to .delete_tenant' do
      expect(@instance).to respond_to :delete_tenant
    end

    it 'is expected to delete a tenant' do
      expect(@instance).to receive(:post).with(
        TENANT_DELETE_PATH, { id: 'test' }
      )
      expect { @instance.delete_tenant('test') }.not_to raise_error
    end
  end

  context '.load_tenant' do
    it 'should respond to .load_tenant' do
      expect(@instance).to respond_to :load_tenant
    end

    it 'is expected to load a tenant' do
      expect(@instance).to receive(:get).with(
        TENANT_LOAD_PATH, { id: 'test' }
      )
      expect { @instance.load_tenant('test') }.not_to raise_error
    end
  end

  context '.load_all_tenants' do
    it 'should respond to .load_all_tenants' do
      expect(@instance).to respond_to :load_all_tenants
    end

    it 'is expected to load all tenants' do
      expect(@instance).to receive(:get).with(TENANT_LOAD_ALL_PATH)
      expect { @instance.load_all_tenants }.not_to raise_error
    end
  end

  context '.search_all_tenants' do
    it 'should respond to .search_all_tenants' do
      expect(@instance).to respond_to :search_all_tenants
    end

    it 'is expected to search all tenants' do
      expect(@instance).to receive(:get).with(
        TENANT_SEARCH_ALL_PATH, {
          ids: %w[test1 test2],
          names: %w[test1 test2],
          selfProvisioningDomains: %w[descope.com descope.io],
          customAttributes: [
            { name: 'test', value: 'test' },
            { name: 'test2', value: 'test2' }
          ]
        }
      )
      expect do
        @instance.search_all_tenants(
          ids: %w[test1 test2],
          names: %w[test1 test2],
          self_provisioning_domains: %w[descope.com descope.io],
          custom_attributes: [
            { name: 'test', value: 'test' },
            { name: 'test2', value: 'test2' }
          ]
        )
      end.not_to raise_error
    end
  end
end
