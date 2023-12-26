# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Flow
          #        List all project flows
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ListFlows/
          def list_flows
            get(FLOW_LIST_PATH)
          end

          # Export the given flow id flow and screens.
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ExportFlow/
          def export_flow(flow_id: nil)
            request_params = { flowId: flow_id }
            get(FLOW_EXPORT_PATH, request_params)
          end

          # Import the given flow and screens.
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ImportFlow/
          def import_flow(flow_id: nil, flow: nil, screens: nil)
            request_params = {
              flowId: flow_id,
              flow: flow,
              screens: screens
            }
            post(FLOW_IMPORT_PATH, request_params)
          end

          # Export the current project theme.
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ExportTheme/
          def export_theme
            post(THEME_EXPORT_PATH)
          end

          # Import the current project theme.
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ImportTheme/
          def import_theme(theme: nil)
            request_params = { theme: theme }
            post(THEME_IMPORT_PATH, request_params)
          end
        end
      end
    end
  end
end
