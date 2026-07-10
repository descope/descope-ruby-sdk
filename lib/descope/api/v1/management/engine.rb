# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for Engine
        module Engine
          include Descope::Api::V1::Management::Common

          def create_engine(name:)
            # Create a new engine with the given name.
            post(ENGINE_CREATE_PATH, { name: })
          end

          def update_engine(id:, name:)
            # Update an existing engine with the given id and name.
            post(ENGINE_UPDATE_PATH, { id:, name: })
          end

          def delete_engine(id:)
            # Delete an existing engine. IMPORTANT: This action is irreversible. Use carefully.
            post(ENGINE_DELETE_PATH, { id: })
          end

          def load_engine(id:)
            # Load engine by id.
            get(ENGINE_LOAD_PATH, { id: })
          end

          def load_all_engines
            # Load all engines.
            get(ENGINE_LOAD_ALL_PATH)
          end

          def rotate_engine_secret(id:)
            # Rotate the secret for the given engine.
            post(ENGINE_ROTATE_SECRET_PATH, { id: })
          end
        end
      end
    end
  end
end
