# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Permission do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Permission)
    @instance = dummy_instance
  end

  context '.create_permission' do
    it 'should respond to .create_permission' do
      expect(@instance).to respond_to :create_permission
    end

    it 'is expected to create a new permission' do
      expect(@instance).to receive(:post).with(
        PERMISSION_CREATE_PATH, {
          name: 'test',
          description: 'test'
        }
      )
      expect do
        @instance.create_permission(
          name: 'test',
          description: 'test'
        )
      end.not_to raise_error
    end
  end

  context '.update_permission' do
    it 'should respond to .update_permission' do
      expect(@instance).to respond_to :update_permission
    end

    it 'is expected to update a permission' do
      expect(@instance).to receive(:post).with(
        PERMISSION_UPDATE_PATH, {
          name: 'test',
          newName: 'production',
          description: 'test'
        }
      )
      expect do
        @instance.update_permission(
          name: 'test',
          new_name: 'production',
          description: 'test'
        )
      end.not_to raise_error
    end
  end

  context '.delete_permission' do
    it 'should respond to .delete_permission' do
      expect(@instance).to respond_to :delete_permission
    end

    it 'is expected to delete a permission' do
      expect(@instance).to receive(:post).with(
        PERMISSION_DELETE_PATH, { name: 'test' }
      )
      expect do
        @instance.delete_permission(name: 'test')
      end.not_to raise_error
    end
  end

  context '.load_all_permissions' do
    it 'should respond to .load_all_permissions' do
      expect(@instance).to respond_to :load_all_permissions
    end

    it 'is expected to delete a permission' do
      expect(@instance).to receive(:get).with(PERMISSION_LOAD_ALL_PATH)
      expect { @instance.load_all_permissions }.not_to raise_error
    end
  end
end
