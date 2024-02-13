# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Flow
          include Descope::Api::V1::Management::Common

          #        List all project flows
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ListFlows/
          # To list all flows, send an empty body such as: { } or { "ids": [] }.
          #
          # To search for a flow or several flows, send a body with the flowIds you want to search such as { "ids": ["sign-in"] } or { "ids": ["sign-in", "sign-up"] }.
          def list_or_search_flows(ids = [])
            request_params = { ids: }
            post(FLOW_LIST_PATH, request_params)
          end

          # Export the given flow id flow and screens.
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ExportFlow/
          def export_flow(flow_id = nil)
            request_params = { flowId: flow_id }
            post(FLOW_EXPORT_PATH, request_params)
          end

          # Import the given flow and screens.
          # @see https://docs.descope.com/api/openapi/flowmanagement/operation/ImportFlow/
          def import_flow(flow_id: nil, flow: nil, screens: nil)
            request_params = {
              flowId: flow_id,
              flow:,
              screens:
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
          def import_theme(theme)
            request_params = { theme: }
            post(THEME_IMPORT_PATH, request_params)
          end
        end
      end
    end
  end
end
