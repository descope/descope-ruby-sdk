# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Role
          def create_role(name: nil, description: nil, permission_names: nil)
            # Create a new role.
            permission_names ||= []
            request_params = {
              name: name,
              description: description,
              permissionNames: permission_names
            }
            post(ROLE_CREATE_PATH, request_params)
          end

          def update_role(name: nil, new_name: nil, description: nil, permission_names: nil)
            # Update an existing role with the given various fields. IMPORTANT: All parameters are used as overrides
            # to the existing role. Empty fields will override populated fields. Use carefully.
            permission_names ||= []
            request_params = {
              name: name,
              newName: new_name,
              description: description,
              permissionNames: permission_names
            }
            post(ROLE_UPDATE_PATH, request_params)
          end

          def delete_role(name)
            # Delete an existing role. IMPORTANT: This action is irreversible. Use carefully.
            post(ROLE_DELETE_PATH, { name: })
          end

          def load_all_roles
            # Load all roles.
            get(ROLE_LOAD_ALL_PATH)
          end
        end
      end
    end
  end
end
