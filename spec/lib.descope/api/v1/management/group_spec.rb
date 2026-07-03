# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Group do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Group)
    @instance = dummy_instance
  end

  context '.load_all_groups' do
    it 'should respond to .load_all_groups' do
      expect(@instance).to respond_to :load_all_groups
    end

    it 'is expected to load all groups for a given tenant id' do
      expect(@instance).to receive(:post).with(
        GROUP_LOAD_ALL_PATH,
        {
          tenantId: 'tenant-id'
        }
      )
      expect do
        @instance.load_all_groups(tenant_id: 'tenant-id')
      end.not_to raise_error
    end
  end

  context '.load_all_groups_for_members' do
    it 'should respond to .load_all_groups_for_members' do
      expect(@instance).to respond_to :load_all_groups_for_members
    end

    it 'is expected to load all groups for the given user and login ids' do
      expect(@instance).to receive(:post).with(
        GROUP_LOAD_ALL_FOR_MEMBER_PATH,
        {
          tenantId: 'tenant-id',
          loginIds: ['login-id'],
          userIds: ['user-id']
        }
      )
      expect do
        @instance.load_all_groups_for_members(
          tenant_id: 'tenant-id',
          user_ids: ['user-id'],
          login_ids: ['login-id']
        )
      end.not_to raise_error
    end
  end

  context '.load_all_group_members' do
    it 'should respond to .load_all_group_members' do
      expect(@instance).to respond_to :load_all_group_members
    end

    it 'is expected to load all members of the given group id' do
      expect(@instance).to receive(:post).with(
        GROUP_LOAD_ALL_GROUP_MEMBERS_PATH,
        {
          tenantId: 'tenant-id',
          groupId: 'group-id'
        }
      )
      expect do
        @instance.load_all_group_members(tenant_id: 'tenant-id', group_id: 'group-id')
      end.not_to raise_error
    end
  end
end
