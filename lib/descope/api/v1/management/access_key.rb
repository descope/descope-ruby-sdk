# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module AccessKey
          include Descope::Mixins::Validation

          def create_access_key(name: nil, expire_time: nil, role_names: nil, key_tenants: nil)
            # Create a new access key.'
            # @see https://docs.descope.com/api/openapi/accesskeymanagement/operation/CreateAccessKey/

            role_names ||= []
            key_tenants ||= []
            validate_tenants(key_tenants)
            post(ACCESS_KEY_CREATE_PATH, access_key_compose_create_body(name, expire_time, role_names, key_tenants))
          end

          def access_key_compose_create_body(name, expire_time, role_names, key_tenants)
            {
              name:,
              expireTime: expire_time,
              roleNames: role_names,
              keyTenants: associated_tenants_to_hash_array(key_tenants)
            }
          end

          def load_access_key(id)
            # Load an access key.'
            # @param id [string] The access key id.
            # @see https://docs.descope.com/api/openapi/accesskeymanagement/operation/LoadAccessKey/

            get(ACCESS_KEY_LOAD_PATH, { id: })
          end

          def search_all_access_keys(tenant_ids = nil)
            # Search all access keys.'
            # @see https://docs.descope.com/api/openapi/accesskeymanagement/operation/SearchAccessKeys/
            request_params = {
              tenantIds: tenant_ids
            }
            post(ACCESS_KEYS_SEARCH_PATH, request_params)
          end

          def update_access_key(id: nil, name: nil)
            # Update an existing access key name
            # @see https://docs.descope.com/api/openapi/accesskeymanagement/operation/UpdateAccessKey/
            request_params = {
              id:,
              name:
            }
            post(ACCESS_KEY_UPDATE_PATH, request_params)
          end

          def deactivate_access_key(id)
            # Deactivate an existing access key. IMPORTANT: This deactivated key will not be usable from this stage.
            # It will, however, persist, and can be activated again if needed.
            # @see https://docs.descope.com/api/openapi/accesskeymanagement/operation/DeactivateAccessKey/
            post(ACCESS_KEY_DEACTIVATE_PATH, { id: })
          end

          def activate_access_key(id)
            # Activate an existing access key. IMPORTANT: Only deactivated keys can be activated again,
            # and become usable once more. New access keys are active by default.
            # @see https://docs.descope.com/api/openapi/accesskeymanagement/operation/ActivateAccessKey/
            post(ACCESS_KEY_ACTIVATE_PATH, { id: })
          end

          def delete_access_key(id)
            # Delete an existing access key. IMPORTANT: This action is irreversible. Use carefully.
            # @see https://docs.descope.com/api/openapi/accesskeymanagement/operation/DeleteAccessKey/
            post(ACCESS_KEY_DELETE_PATH, { id: })
          end
        end
      end
    end
  end
end
