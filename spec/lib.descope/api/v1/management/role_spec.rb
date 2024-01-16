# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Role do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Role)
    @instance = dummy_instance
  end

  context '.create_role' do
    it 'should respond to .create_role' do
      expect(@instance).to respond_to :create_role
    end

    it 'is expected to create a new role' do
      expect(@instance).to receive(:post).with(
        ROLE_CREATE_PATH, {
          name: 'test',
          description: 'test',
          permissionNames: ['test']
        }
      )
      expect do
        @instance.create_role(
          name: 'test',
          description: 'test',
          permission_names: ['test']
        )
      end.not_to raise_error
    end
  end

  context '.update_role' do
    it 'should respond to .update_role' do
      expect(@instance).to respond_to :update_role
    end

    it 'is expected to update a role' do
      expect(@instance).to receive(:post).with(
        ROLE_UPDATE_PATH, {
          name: 'test',
          newName: 'production',
          description: 'test',
          permissionNames: ['test']
        }
      )
      expect do
        @instance.update_role(
          name: 'test',
          new_name: 'production',
          description: 'test',
          permission_names: ['test']
        )
      end.not_to raise_error
    end
  end

  context '.delete_role' do
    it 'should respond to .delete_role' do
      expect(@instance).to respond_to :delete_role
    end

    it 'is expected to delete a role' do
      expect(@instance).to receive(:post).with(
        ROLE_DELETE_PATH, { name: 'test' }
      )
      expect do
        @instance.delete_role('test')
      end.not_to raise_error
    end
  end

  context '.load_all_roles' do
    it 'should respond to .load_all_roles' do
      expect(@instance).to respond_to :load_all_roles
    end

    it 'is expected to delete a role' do
      expect(@instance).to receive(:get).with(ROLE_LOAD_ALL_PATH)
      expect { @instance.load_all_roles }.not_to raise_error
    end
  end
end
