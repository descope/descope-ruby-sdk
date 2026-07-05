# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for FGA (Fine-Grained Authorization)
        module FGA
          include Descope::Api::V1::Management::Common

          def fga_save_schema(schema: nil)
            # Create or update the FGA schema.
            # schema (String): the schema DSL string.
            post(FGA_SAVE_SCHEMA_PATH, { dsl: schema })
          end

          def fga_load_schema
            # Load the FGA schema for the project.
            get(FGA_LOAD_SCHEMA_PATH)
          end

          def fga_create_relations(tuples: nil)
            # Create the given relations (tuples) based on the existing schema.
            post(FGA_CREATE_RELATIONS_PATH, { tuples: })
          end

          def fga_delete_relations(tuples: nil)
            # Delete the given relations (tuples) based on the existing schema.
            post(FGA_DELETE_RELATIONS_PATH, { tuples: })
          end

          def fga_check(tuples: nil)
            # Check the given relations (tuples) to see if they are allowed.
            post(FGA_CHECK_PATH, { tuples: })
          end

          def fga_load_mappable_schema(tenant_id: nil, options: nil)
            # Load the mappable schema for the given tenant.
            request_params = { tenantId: tenant_id }
            request_params[:resourcesLimit] = options[:resourcesLimit] if options && options[:resourcesLimit]
            get(FGA_LOAD_MAPPABLE_SCHEMA_PATH, request_params)
          end

          def fga_search_mappable_resources(tenant_id: nil, resources_queries: nil, options: nil)
            # Search for mappable resources for the given tenant.
            request_params = { tenantId: tenant_id, resourcesQueries: resources_queries }
            request_params[:resourcesLimit] = options[:resourcesLimit] if options && options[:resourcesLimit]
            post(FGA_SEARCH_MAPPABLE_RESOURCES_PATH, request_params)
          end

          def fga_load_resources_details(resource_identifiers: nil)
            # Load the details of the given resource identifiers.
            post(FGA_RESOURCES_LOAD_PATH, { resourceIdentifiers: resource_identifiers })
          end

          def fga_save_resources_details(resources_details: nil)
            # Save the details of the given resources.
            post(FGA_RESOURCES_SAVE_PATH, { resourcesDetails: resources_details })
          end
        end
      end
    end
  end
end
