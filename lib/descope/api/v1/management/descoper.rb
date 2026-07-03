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
            put(DESCOPER_CREATE_PATH, { descopers: descopers })
          end

          def update_descoper(id: nil, attributes: nil, rbac: nil)
            # Update the given descoper by id.
            request_params = {
              id: id,
              attributes: attributes,
              rbac: rbac
            }
            patch(DESCOPER_UPDATE_PATH, request_params)
          end

          def get_descoper(id: nil)
            # Get a descoper by id.
            get(DESCOPER_GET_PATH, { id: id })
          end

          def delete_descoper(id: nil)
            # Delete a descoper by id.
            delete(DESCOPER_DELETE_PATH, { id: id })
          end

          def search_descopers
            # Search (list) all descopers.
            post(DESCOPER_SEARCH_PATH, {})
          end
        end
      end
    end
  end
end
