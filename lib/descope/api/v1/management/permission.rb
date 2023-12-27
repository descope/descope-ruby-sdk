# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Permission
          include Descope::Mixins::Validation

          def create_permission(name:, description: nil)
            # Create a new permission.
            # @see https://docs.descope.com/api/openapi/permissionmanagement/operation/CreatePermission/
            request_params = {
              name: name,
              description: description
            }
            post(PERMISSION_CREATE_PATH, request_params)
          end

          def update_permission(name: nil, new_name: nil, description: nil)
            # Update an existing permission with the given various fields. IMPORTANT: All parameters are used as overrides
            # to the existing permission. Empty fields will override populated fields. Use carefully.
            # @see https://docs.descope.com/api/openapi/permissionmanagement/operation/UpdatePermission/
            request_params = {
              name: name,
              newName: new_name,
              description: description
            }
            post(PERMISSION_UPDATE_PATH, request_params)
          end

          def delete_permission(name:)
            # Delete an existing permission. IMPORTANT: This action is irreversible. Use carefully.
            post(PERMISSION_DELETE_PATH, { name: name })
          end

          def load_all_permissions
            # Load all permissions.
            get(PERMISSION_LOAD_ALL_PATH)
          end
        end
      end
    end
  end
end
