# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module SCIM
          def scim_search_groups(filter: nil, start_index: nil, count: nil, excluded_attributes: nil)
            # Search SCIM Groups
            url = compose_scim_search_groups_url(filter, start_index, count, excluded_attributes)
            get(url)
          end

          def scim_create_group(group_id: nil, display_name: nil, members: nil, external_id: nil,
                                excluded_attributes: nil)
            # Create SCIM Group
            body = compose_scim_create_group_body(group_id, display_name, members, external_id, excluded_attributes)
            post(SCIM_GROUPS_PATH, body)
          end

          def scim_load_group(group_id: nil, display_name: nil, external_id: nil, excluded_attributes: nil)
            # Load SCIM Group, using a valid access key.
            validate_scim_group_id(group_id)
            url = compose_scim_create_group_url(group_id, display_name, external_id, excluded_attributes)
            get(url)
          end

          def scim_update_group(group_id: nil, display_name: nil, members: nil, external_id: nil,
                                excluded_attributes: nil)
            # Update SCIM Group, using a valid access key.
            validate_scim_group_id(group_id)
            body = compose_scim_update_group_body(group_id, display_name, members, external_id, excluded_attributes)
            patch("#{SCIM_GROUPS_PATH}/#{group_id}", body)
          end

          def scim_delete_group(group_id)
            # Delete SCIM Group, using a valid access key.
            validate_scim_group_id(group_id)
            url = "#{SCIM_GROUPS_PATH}/#{group_id}"
            delete(url)
          end

          def scim_patch_group(group_id: nil, user_id: nil, operations: nil)
            # Patch SCIM Group, using a valid access key.
            validate_scim_group_id(group_id)
            url = compose_scim_patch_group_url(group_id, user_id, operations)
            patch(url)
          end

          # SCIM Users
          def scim_load_resource_types
            # Load SCIM Resource Types, using a valid access key.
            get(SCIM_RESOURCE_TYPES_PATH)
          end

          def scim_load_service_provider_config
            # Load SCIM Service Provider Config, using a valid access key.
            get(SCIM_SERVICE_PROVIDER_CONFIG_PATH)
          end

          def scim_search_users(filter: nil, start_index: nil, count: nil)
            # Search SCIM Users, using a valid access key.
            url = compose_scim_search_users_url(filter, start_index, count)
            get(url)
          end

          def scim_create_user(user_id: nil, display_name: nil, emails: nil,
                               phone_numbers: nil, active: nil, name: nil, user_name: nil)
            # Create SCIM User, using a valid access key.
            validate_user_id(user_id)
            body = compose_scim_create_user_body(user_id, display_name, emails, phone_numbers, active, name, user_name)
            post(SCIM_USERS_PATH, body)
          end

          def scim_load_user(user_id)
            # Load SCIM User, using a valid access key.
            validate_user_id(user_id)
            url = "#{SCIM_USERS_PATH}/#{user_id}"
            get(url)
          end

          def scim_update_user(user_id)
            # Update SCIM User, using a valid access key.
            validate_user_id(user_id)
            url = "#{SCIM_USERS_PATH}/#{user_id}"
            patch(url)
          end

          def scim_delete_user(user_id)
            # Delete SCIM User, using a valid access key.
            validate_user_id(user_id)
            url = "#{SCIM_USERS_PATH}/#{user_id}"
            delete(url)
          end

          def scim_patch_user(user_id: nil, group_id: nil, operations: nil)
            # Patch SCIM User, using a valid access key.
            validate_user_id(user_id)
            validate_scim_group_id(group_id)
            body = compose_scim_patch_user_body(user_id, group_id, operations)
            patch(SCIM_USERS_PATH, body)
          end

          private

          def compose_scim_search_groups_url(filter, start_index, count, excluded_attributes)
            url = "#{SCIM_GROUPS_PATH}?"
            url += "filter=#{filter}&" unless filter.nil?
            url += "startIndex=#{start_index}&" unless start_index.nil?
            url += "count=#{count}&" unless count.nil?
            url += "excludedAttributes=#{excluded_attributes}&" unless excluded_attributes.nil?
            url
          end

          def compose_scim_create_group_body(group_id, display_name, members, external_id, excluded_attributes)
            body = {}
            body['id'] = group_id unless group_id.nil?
            body['displayName'] = display_name unless display_name.nil?
            body['members'] = members unless members.nil?
            body['externalId'] = external_id unless external_id.nil?
            body['excludedAttributes'] = excluded_attributes unless excluded_attributes.nil?
            body
          end

          def compose_scim_create_group_url(group_id, display_name, external_id, excluded_attributes)
            display_name = CGI.escape(display_name) unless display_name.nil?
            url = "#{SCIM_GROUPS_PATH}/#{group_id}?"
            url += "displayName=#{display_name}&" unless display_name.nil?
            url += "externalId=#{external_id}&" unless external_id.nil?
            url += "excludedAttributes=#{excluded_attributes}" unless excluded_attributes.nil?
            url
          end

          def compose_scim_update_group_body(group_id, display_name, members, external_id, excluded_attributes)
            body = {}
            body[:groupId] = group_id unless group_id.nil?
            body[:displayName] = display_name unless display_name.nil?
            body[:members] = members unless members.nil?
            body[:externalId] = external_id unless external_id.nil?
            body[:excludedAttributes] = excluded_attributes unless excluded_attributes.nil?
            body
          end

          def compose_scim_patch_group_url(group_id, user_id, operations)
            url = "#{SCIM_GROUPS_PATH}/#{group_id}&"
            url += "userId=#{user_id}&" unless user_id.nil?
            url += "operations=#{compose_operations_param(operations)}&" unless operations.nil?
            url
          end

          def compose_scim_search_users_url(filter, start_index, count)
            url = "#{SCIM_USERS_PATH}?"
            url += "filter=#{filter}&" unless filter.nil?
            url += "startIndex=#{start_index}&" unless start_index.nil?
            url += "count=#{count}&" unless count.nil?
            url
          end

          def compose_scim_create_user_body(user_id, display_name, emails, phone_numbers, active, name, user_name)
            raise AuthException.new('name must be a hash of these fields: given_name, family_name, last_name') if !name.nil? && !name.is_a?(Hash)

            body = {}
            body[:userId] = user_id unless user_id.nil?
            body[:displayName] = display_name unless display_name.nil?
            body[:emails] = emails unless emails.nil?
            body[:phoneNumbers] = phone_numbers unless phone_numbers.nil?
            body[:active] = active unless active.nil?
            body[:name] = {} unless name.nil?
            body[:name][:givenName] = name[:given_name] unless name[:given_name].nil?
            body[:name][:familyName] = name[:family_name] unless name[:family_name].nil?
            body[:name][:middleName] = name[:middle_name] unless name[:middle_name].nil?
            body[:userName] = user_name unless user_name.nil?
            body
          end

          def compose_operations_param(operations)
            operations_params = []
            if operations.is_a?(Array)
              operations.each do |op|
                operations_params << {
                  op: op[:op],
                  path: op[:path],
                  valueString: op[:value_string],
                  valueBoolean: op[:value_boolean],
                  valueArray: op[:value_array]
                }
              end
            end
            operations_params
          end

          def compose_scim_patch_user_body(user_id, group_id, operations)
            body = {}
            body[:userId] = user_id unless user_id.nil?
            body[:groupId] = group_id unless group_id.nil?
            body[:operations] = operations unless operations.nil?
            body
          end
        end
      end
    end
  end
end
