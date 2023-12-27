# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Project
          def rename_project(name: nil)
            # Rename a project.
            post(PROJECT_UPDATE_NAME, { name: name })
          end

          def export_project(format: nil)
            # Export a project.
            # The response is the JSON of the project items when the format is string.
            request_params = {}
            request_params[:format] = format unless format.nil?
            res = post(PROJECT_EXPORT_PATH, request_params)
            if format == 'string'
              res.to_json
            else
              res
            end
          end

          def import_project(files: nil)
            # Import a project.
            # The argument of files should be the output of the export project endpoint
            post(PROJECT_IMPORT_PATH, { files: files })
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
              name: name,
              tag: tag
            }
            post(PROJECT_CLONE, request_params)
          end
        end
      end
    end
  end
end
