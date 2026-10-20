# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for Descoper
        module Descoper
          include Descope::Api::V1::Management::Common

          def create_descoper(descopers = nil)
            # Create the given descopers.
            # descopers (Array): the descopers to create.
            mgmt_put(DESCOPER_CREATE_PATH, { descopers: descopers })
          end

          def update_descoper(id: nil, attributes: nil, rbac: nil)
            # Update the given descoper by id.
            request_params = {
              id: id,
              attributes: attributes,
              rbac: rbac
            }
            mgmt_patch(DESCOPER_UPDATE_PATH, request_params)
          end

          def get_descoper(id: nil)
            # Get a descoper by id.
            mgmt_get(DESCOPER_GET_PATH, { id: id })
          end

          def delete_descoper(id: nil)
            # Delete a descoper by id.
            mgmt_delete(DESCOPER_DELETE_PATH, { id: id })
          end

          def search_descopers
            # Search (list) all descopers.
            mgmt_post(DESCOPER_SEARCH_PATH, {})
          end
        end
      end
    end
  end
end
