# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::ManagementKey do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::ManagementKey)
    @instance = dummy_instance
  end

  context '.create_management_key' do
    it 'should respond to .create_management_key' do
      expect(@instance).to respond_to :create_management_key
    end

    it 'is expected to create a management key' do
      expect(@instance).to receive(:put).with(
        MGMT_KEY_CREATE_PATH, {
          name: 'test',
          description: 'test key',
          expiresIn: 0,
          permittedIps: ['1.2.3.4'],
          reBac: { 'k1': 'v1' }
        }
      )
      expect do
        @instance.create_management_key(
          name: 'test',
          description: 'test key',
          expires_in: 0,
          permitted_ips: ['1.2.3.4'],
          re_bac: { 'k1': 'v1' }
        )
      end.not_to raise_error
    end
  end

  context '.update_management_key' do
    it 'should respond to .update_management_key' do
      expect(@instance).to respond_to :update_management_key
    end

    it 'is expected to update a management key' do
      expect(@instance).to receive(:patch).with(
        MGMT_KEY_UPDATE_PATH, {
          id: '123',
          name: 'test1',
          description: 'updated',
          permittedIps: ['1.2.3.4'],
          status: 'active'
        }
      )
      expect do
        @instance.update_management_key(
          id: '123',
          name: 'test1',
          description: 'updated',
          permitted_ips: ['1.2.3.4'],
          status: 'active'
        )
      end.not_to raise_error
    end
  end

  context '.get_management_key' do
    it 'should respond to .get_management_key' do
      expect(@instance).to respond_to :get_management_key
    end

    it 'is expected to get a management key' do
      expect(@instance).to receive(:get).with(
        MGMT_KEY_GET_PATH, { id: '123' }
      )
      expect { @instance.get_management_key(id: '123') }.not_to raise_error
    end
  end

  context '.delete_management_key' do
    it 'should respond to .delete_management_key' do
      expect(@instance).to respond_to :delete_management_key
    end

    it 'is expected to delete a management key' do
      expect(@instance).to receive(:post).with(
        MGMT_KEY_DELETE_PATH, { ids: ['123'] }
      )
      expect { @instance.delete_management_key(id: '123') }.not_to raise_error
    end
  end

  context '.search_management_keys' do
    it 'should respond to .search_management_keys' do
      expect(@instance).to respond_to :search_management_keys
    end

    it 'is expected to search management keys' do
      expect(@instance).to receive(:get).with(
        MGMT_KEY_SEARCH_PATH, {
          tenantIds: %w[123 456],
          status: 'active'
        }
      )
      expect do
        @instance.search_management_keys(tenant_ids: %w[123 456], status: 'active')
      end.not_to raise_error
    end
  end
end
