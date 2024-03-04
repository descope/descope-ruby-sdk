# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Role
          include Descope::Api::V1::Management::Common

          def create_role(name: nil, description: nil, permission_names: nil, tenant_id: nil)
            # Create a new role.
            permission_names ||= []
            request_params = {
              name:,
              description:,
              permissionNames: permission_names,
              tenantId: tenant_id
            }
            post(ROLE_CREATE_PATH, request_params)
          end

          def update_role(name: nil, new_name: nil, description: nil, permission_names: nil, tenant_id: nil)
            # Update an existing role with the given various fields. IMPORTANT: All parameters are used as overrides
            # to the existing role. Empty fields will override populated fields. Use carefully.
            permission_names ||= []
            request_params = {
              name:,
              newName: new_name,
              description:,
              permissionNames: permission_names,
              tenantId: tenant_id
            }
            post(ROLE_UPDATE_PATH, request_params)
          end

          def delete_role(name: nil, tenant_id: nil)
            # Delete an existing role. IMPORTANT: This action is irreversible. Use carefully.
            request_params = { name: }
            request_params[:tenantId] = tenant_id if tenant_id
            post(ROLE_DELETE_PATH, request_params)
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
