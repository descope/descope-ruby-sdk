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
            raise Descope::ArgumentError, 'name is required' if name.nil? || name.empty?

            request_params = { name: }
            request_params[:tenantId] = tenant_id if tenant_id
            post(ROLE_DELETE_PATH, request_params)
          end

          def load_all_roles
            # Load all roles.
            get(ROLE_LOAD_ALL_PATH)
          end

          def search_roles(role_names: nil, tenant_ids: nil, role_name_like: nil, permission_names: nil)
            # Search for roles using the given parameters.
            request_params = {}
            request_params[:roleNames] = role_names if role_names
            request_params[:tenantIds] = tenant_ids if tenant_ids
            request_params[:roleNameLike] = role_name_like if role_name_like
            request_params[:permissionNames] = permission_names if permission_names
            post(ROLE_SEARCH_PATH, request_params)
          end
        end
      end
    end
  end
end
