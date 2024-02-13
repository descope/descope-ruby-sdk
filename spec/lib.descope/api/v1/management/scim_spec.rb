# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::SCIM do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::SCIM)
    @instance = dummy_instance
  end

  context '.scim_search_groups' do
    it 'should respond to .scim_search_groups' do
      expect(@instance).to respond_to :scim_search_groups
    end

    it 'is expected to get scim groups' do
      filter = 'filter'
      start_index = 1
      count = 10
      excluded_attributes = { abc: '123' }
      url = @instance.send(:compose_scim_search_groups_url,
                           filter,
                           start_index,
                           count,
                           excluded_attributes)
      expect(@instance).to receive(:get).with(url)
      expect do
        @instance.scim_search_groups(filter:, start_index:, count:, excluded_attributes:)
      end.not_to raise_error
    end
  end

  context '.scim_create_group' do
    it 'should respond to .scim_create_group' do
      expect(@instance).to respond_to :scim_create_group
    end

    it 'is expected to create scim group' do
      group_id = 'group_id'
      display_name = 'display_name'
      members = ['members']
      external_id = 'external_id'
      excluded_attributes = { abc: '123' }
      body = @instance.send(:compose_scim_create_group_body,
                            group_id,
                            display_name,
                            members,
                            external_id,
                            excluded_attributes)
      expect(@instance).to receive(:post).with(Descope::Api::V1::Management::Common::SCIM_GROUPS_PATH, body)
      expect do
        @instance.scim_create_group(group_id:,
                                    display_name:,
                                    members:,
                                    external_id:,
                                    excluded_attributes:)
      end.not_to raise_error
    end
  end

  context '.scim_load_group' do
    it 'should respond to .scim_load_group' do
      expect(@instance).to respond_to :scim_load_group
    end

    it 'is expected to load scim group' do
      group_id = 'G123'
      display_name = 'for display'
      external_id = '1234'
      excluded_attributes = { 'some': 'thing' }
      url = @instance.send(
        :compose_scim_create_group_url,
        group_id, display_name, external_id, excluded_attributes
      )
      expect(@instance).to receive(:get).with(url)
      expect do
        @instance.scim_load_group(group_id:, display_name:, external_id:, excluded_attributes:)
      end.not_to raise_error
    end
  end

  context '.scim_update_group' do
    it 'should respond to .scim_update_group' do
      expect(@instance).to respond_to :scim_update_group
    end

    it 'is expected to update scim group' do
      group_id = 'G123'
      display_name = 'for display'
      members = ['member1']
      external_id = '1234'
      excluded_attributes = { 'some': 'thing' }
      body = @instance.send(
        :compose_scim_update_group_body,
        group_id, display_name, members, external_id, excluded_attributes
      )
      url = "#{SCIM_GROUPS_PATH}/#{group_id}"
      expect(@instance).to receive(:patch).with(url, body)
      expect do
        @instance.scim_update_group(group_id:, display_name:, members:, external_id:, excluded_attributes:)
      end.not_to raise_error
    end
  end

  context '.scim_delete_group' do
    it 'should respond to .scim_delete_group' do
      expect(@instance).to respond_to :scim_delete_group
    end

    it 'is expected to delete scim group' do
      group_id = 'G123'
      url = "#{SCIM_GROUPS_PATH}/#{group_id}"
      expect(@instance).to receive(:delete).with(url)
      expect { @instance.scim_delete_group(group_id) }.not_to raise_error
    end
  end

  context '.scim_patch_group' do
    it 'should respond to .scim_patch_group' do
      expect(@instance).to respond_to :scim_patch_group
    end

    it 'is expected to patch scim group' do
      group_id = 'G123'
      user_id = 'U123'
      operations = [
        {
          op: 'add',
          path: '/auth',
          value_string: 'something',
          value_boolean: 'true',
          value_array: [1, 2, 3]
        }, {
          op: 'remove',
          path: '/authOTP',
          value_string: 'done',
          value_boolean: 'false',
          value_array: [4, 5, 6]
        }
      ]

      url = @instance.send(:compose_scim_patch_group_url, group_id, user_id, operations)

      expect(@instance).to receive(:patch).with(url)
      expect do
        @instance.scim_patch_group(group_id:, user_id:, operations:)
      end.not_to raise_error
    end
  end

  context '.scim_load_resource_types' do
    it 'should respond to .scim_load_resource_types' do
      expect(@instance).to respond_to :scim_load_resource_types
    end

    it 'is expected to load scim resource types' do
      url = "#{SCIM_RESOURCE_TYPES_PATH}"
      expect(@instance).to receive(:get).with(url)
      expect { @instance.scim_load_resource_types }.not_to raise_error
    end
  end

  context '.scim_load_service_provider_config' do
    it 'should respond to .scim_load_service_provider_config' do
      expect(@instance).to respond_to :scim_load_service_provider_config
    end

    it 'is expected to load scim service provider config' do
      url = "#{SCIM_SERVICE_PROVIDER_CONFIG_PATH}"
      expect(@instance).to receive(:get).with(url)
      expect { @instance.scim_load_service_provider_config }.not_to raise_error
    end
  end

  context '.scim_search_users' do
    it 'should respond to .scim_search_users' do
      expect(@instance).to respond_to :scim_search_users
    end

    it 'is expected to search scim users' do
      filter = 'filter'
      start_index = 1
      count = 10
      url = @instance.send(:compose_scim_search_users_url,
                           filter,
                           start_index,
                           count)
      expect(@instance).to receive(:get).with(url)
      expect do
        @instance.scim_search_users(filter:, start_index:, count:)
      end.not_to raise_error
    end
  end

  context '.scim_create_user' do
    it 'should respond to .scim_create_user' do
      expect(@instance).to respond_to :scim_create_user
    end

    it 'is expected to create scim user' do
      user_id = 'user_id'
      display_name = 'display_name'
      emails = ['email']
      phone_numbers = ['phone_number']
      active = true
      name = {
        given_name: 'given_name',
        family_name: 'family_name',
        last_name: 'last_name'
      }
      user_name = 'user_name'

      body = @instance.send(:compose_scim_create_user_body,
                            user_id,
                            display_name,
                            emails,
                            phone_numbers,
                            active,
                            name,
                            user_name)
      expect(@instance).to receive(:post).with(SCIM_USERS_PATH, body)
      expect do
        @instance.scim_create_user(
          user_id:,
          display_name:,
          emails:,
          phone_numbers:,
          active:,
          name:,
          user_name:
        )
      end.not_to raise_error
    end
  end

  context '.scim_load_user' do
    it 'should respond to .scim_load_user' do
      expect(@instance).to respond_to :scim_load_user
    end

    it 'is expected to load scim user' do
      user_id = 'U123'
      url = "#{SCIM_USERS_PATH}/#{user_id}"
      expect(@instance).to receive(:get).with(url)
      expect do
        @instance.scim_load_user(user_id)
      end.not_to raise_error
    end
  end

  context '.scim_update_user' do
    it 'should respond to .scim_update_user' do
      expect(@instance).to respond_to :scim_update_user
    end

    it 'is expected to load scim user' do
      user_id = 'U123'
      url = "#{SCIM_USERS_PATH}/#{user_id}"
      expect(@instance).to receive(:patch).with(url)
      expect do
        @instance.scim_update_user(user_id)
      end.not_to raise_error
    end
  end

  context '.scim_delete_user' do
    it 'should respond to .scim_delete_user' do
      expect(@instance).to respond_to :scim_delete_user
    end

    it 'is expected to delete scim user' do
      user_id = 'U123'
      url = "#{SCIM_USERS_PATH}/#{user_id}"
      expect(@instance).to receive(:delete).with(url)
      expect { @instance.scim_delete_user(user_id) }.not_to raise_error
    end
  end

  context '.scim_patch_user' do
    it 'should respond to .scim_patch_user' do
      expect(@instance).to respond_to :scim_patch_user
    end

    it 'is expected to patch scim user' do
      user_id = 'U123'
      group_id = 'G123'
      operations = [
        {
          op: 'add',
          path: '/auth',
          value_string: 'something',
          value_boolean: 'true',
          value_array: [1, 2, 3]
        }, {
          op: 'remove',
          path: '/authOTP',
          value_string: 'done',
          value_boolean: 'false',
          value_array: [4, 5, 6]
        }
      ]

      body = @instance.send(:compose_scim_patch_user_body, user_id, group_id, operations)

      expect(@instance).to receive(:patch).with(SCIM_USERS_PATH, body)
      expect do
        @instance.scim_patch_user(user_id:, group_id:, operations:)
      end.not_to raise_error
    end
  end
end
