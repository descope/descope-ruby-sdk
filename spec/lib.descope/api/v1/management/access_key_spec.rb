# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::AccessKey do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::AccessKey)
    @instance = dummy_instance
  end

  context '.create' do
    it 'should respond to .create_access_key' do
      expect(@instance).to respond_to :create_access_key
    end

    it 'is expected to create access key' do
      expect(@instance).to receive(:post).with(
        ACCESS_KEY_CREATE_PATH, {
          name: 'test',
          expireTime: 0,
          roleNames: ['test'],
          keyTenants: [
            { tenantId: 'test', roleNames: %w[test test2] }
          ],
          customClaims: {'k1', 'v1'}
        }
      )
      expect do
        @instance.create_access_key(
          name: 'test',
          expire_time: 0,
          role_names: ['test'],
          key_tenants: [
            { tenant_id: 'test', role_names: %w[test test2] }
          ],
          custom_claims: {'k1': 'v1'}
        )
      end.not_to raise_error
    end
  end

  context '.load' do
    it 'should respond to .load_access_key' do
      expect(@instance).to respond_to :load_access_key
    end

    it 'is expected to load an access key' do
      expect(@instance).to receive(:get).with(
        ACCESS_KEY_LOAD_PATH, { id: '123' }
      )
      expect { @instance.load_access_key('123') }.not_to raise_error
    end
  end

  context '.search_all_access_keys' do
    it 'should respond to .search_all_access_keys_access_key' do
      expect(@instance).to respond_to :search_all_access_keys
    end

    it 'is expected to search all access keys' do
      expect(@instance).to receive(:post).with(
        ACCESS_KEYS_SEARCH_PATH, { tenantIds: %w[123 456] }
      )
      expect { @instance.search_all_access_keys(%w[123 456]) }.not_to raise_error
    end
  end

  context '.update_access_key' do
    it 'should respond to .update_access_key' do
      expect(@instance).to respond_to :update_access_key
    end

    it 'is expected to update an access keys' do
      expect(@instance).to receive(:post).with(
        ACCESS_KEY_UPDATE_PATH, { id: '123', name: 'test1' }
      )
      expect { @instance.update_access_key(id: '123', name: 'test1') }.not_to raise_error
    end
  end

  context '.deactivate_access_key' do
    it 'should respond to .deactivate_access_key' do
      expect(@instance).to respond_to :deactivate_access_key
    end

    it 'is expected to deactivate an access keys' do
      expect(@instance).to receive(:post).with(
        ACCESS_KEY_DEACTIVATE_PATH, { id: '123' }
      )
      expect { @instance.deactivate_access_key('123') }.not_to raise_error
    end
  end

  context '.activate_access_key' do
    it 'should respond to .activate_access_key' do
      expect(@instance).to respond_to :activate_access_key
    end

    it 'is expected to activate an access keys' do
      expect(@instance).to receive(:post).with(
        ACCESS_KEY_ACTIVATE_PATH, { id: '123' }
      )
      expect { @instance.activate_access_key('123') }.not_to raise_error
    end
  end

  context '.delete_access_key' do
    it 'should respond to .delete_access_key' do
      expect(@instance).to respond_to :delete_access_key
    end

    it 'is expected to delete an access keys' do
      expect(@instance).to receive(:post).with(
        ACCESS_KEY_DELETE_PATH, { id: '123' }
      )
      expect { @instance.delete_access_key('123') }.not_to raise_error
    end
  end
end
