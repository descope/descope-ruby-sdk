# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Project
          include Descope::Api::V1::Management::Common

          def rename_project(name)
            # Rename a project.
            post(PROJECT_UPDATE_NAME, { name: })
          end

          def export_project
            # Exports all settings and configurations for a project and returns the
            #   raw JSON files response as an object.
            #    - This action is supported only with a pro license or above.
            #    - Users, tenants and access keys are not cloned.
            #    - Secrets, keys and tokens are not stripped from the exported data.
            #   @returns a HASH containing the exported JSON files payload.
            post(PROJECT_EXPORT_PATH)
          end

          def import_project(files: nil, excludes: nil)
            # Import a project.
            # The argument of files should be the output of the export project endpoint
            body = { files: }
            body[:excludes] = excludes unless excludes.nil?
            post(PROJECT_IMPORT_PATH, body)
          end

          def delete_project
            # Delete the current project. IMPORTANT: This action is irreversible. Use carefully.
            post(PROJECT_DELETE_PATH)
          end

          def clone_project(name: nil, tag: nil)
            # Clone the current project, including its settings and configurations.
            # - This action is supported only with a pro license or above.
            # - Users, tenants and access keys are not cloned.
            request_params = {
              name:,
              tag:
            }
            post(PROJECT_CLONE, request_params)
          end
        end
      end
    end
  end
end
