# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Manage project-wide OIDC scope-to-claim mapping
        module ScopeClaimMapping
          include Descope::Api::V1::Management::Common

          def get_scope_claim_mapping # rubocop:disable Naming/AccessorMethodName
            # Get the project-wide OIDC scope-to-claim mappings.
            post(SCOPE_CLAIM_MAPPING_GET_PATH)
          end

          def set_scope_claim_mapping(mappings: nil)
            # Set the project-wide OIDC scope-to-claim mappings.
            # mappings (Array[]): the scope-to-claim mappings to set. Each in the following format:
            #   {
            #       "scope": "name of the OIDC scope",
            #       "claims": ["list of claims mapped to the scope"]
            #   }
            post(SCOPE_CLAIM_MAPPING_SET_PATH, { mappings: })
          end

          def delete_scope_claim_mapping
            # Delete the project-wide OIDC scope-to-claim mappings.
            post(SCOPE_CLAIM_MAPPING_DELETE_PATH)
          end
        end
      end
    end
  end
end
