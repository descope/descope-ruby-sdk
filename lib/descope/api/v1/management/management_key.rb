# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for management keys
        module ManagementKey
          include Descope::Api::V1::Management::Common

          def create_management_key(name:, description: nil, expires_in: 0, permitted_ips: nil, re_bac: nil)
            # Create a new management key.
            put(MGMT_KEY_CREATE_PATH, {
                  name:,
                  description:,
                  expiresIn: expires_in,
                  permittedIps: permitted_ips,
                  reBac: re_bac
                })
          end

          def update_management_key(id:, name:, description: nil, permitted_ips: nil, status: nil)
            # Update an existing management key.
            patch(MGMT_KEY_UPDATE_PATH, {
                    id:,
                    name:,
                    description:,
                    permittedIps: permitted_ips,
                    status:
                  })
          end

          def get_management_key(id:)
            # Load an existing management key.
            get(MGMT_KEY_GET_PATH, { id: })
          end

          def delete_management_key(id:)
            # Delete an existing management key.
            post(MGMT_KEY_DELETE_PATH, { ids: [id] })
          end

          def search_management_keys(tenant_ids: nil, status: nil)
            # Search all management keys.
            get(MGMT_KEY_SEARCH_PATH, {
                  tenantIds: tenant_ids,
                  status:
                })
          end
        end
      end
    end
  end
end
