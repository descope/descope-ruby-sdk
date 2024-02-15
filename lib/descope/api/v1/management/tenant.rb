# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Tenant
          include Descope::Mixins::Validation
          include Descope::Api::V1::Management::Common


          def create_tenant(name: nil, id: nil, self_provisioning_domains: nil, custom_attributes: nil)
            # Create a new tenant with the given name. Tenant IDs are provisioned automatically, but can be provided
            # explicitly if needed. Both the name and ID must be unique per project.
            # @see https://docs.descope.com/api/openapi/tenantmanagement/operation/CreateTenant/

            self_provisioning_domains ||= []
            custom_attributes ||= {}
            post(TENANT_CREATE_PATH, compose_tenant_create_update_body(name, id, self_provisioning_domains, custom_attributes))
          end

          def update_tenant(name: nil, id: nil, self_provisioning_domains: nil, custom_attributes: nil)
            #  Update an existing tenant with the given name and domains. IMPORTANT: All parameters are used as overrides
            #  to the existing tenant. Empty fields will override populated fields. Use carefully.
            # @see https://docs.descope.com/api/openapi/tenantmanagement/operation/UpdateTenant/
            self_provisioning_domains ||= []
            custom_attributes ||= {}
            post(TENANT_UPDATE_PATH, compose_tenant_create_update_body(name, id, self_provisioning_domains, custom_attributes))
          end

          def delete_tenant(id = nil)
            # Delete an existing tenant. IMPORTANT: This action is irreversible. Use carefully.
            post(TENANT_DELETE_PATH, { id: })
          end

          def load_tenant(id = nil)
            # Load tenant by id.
            get(TENANT_LOAD_PATH, { id: })
          end

          def load_all_tenants
            # Load all tenants.
            get(TENANT_LOAD_ALL_PATH)
          end

          def search_all_tenants(ids: nil, names: nil, self_provisioning_domains: nil, custom_attributes: nil)
            # Search all tenants.
            request_params = {
              ids:,
              names:,
              selfProvisioningDomains: self_provisioning_domains,
              customAttributes: custom_attributes
            }
            post(TENANT_SEARCH_ALL_PATH, request_params)
          end

          private

          def compose_tenant_create_update_body(name, id, self_provisioning_domains, custom_attributes)
            body = { name:, id: }
            body[:selfProvisioningDomains] = self_provisioning_domains unless self_provisioning_domains.empty?
            body[:customAttributes] = custom_attributes unless custom_attributes.empty?

            body
          end
        end
      end
    end
  end
end
