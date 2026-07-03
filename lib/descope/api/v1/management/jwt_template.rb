# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for JWT templates
        module JWTTemplate
          include Descope::Api::V1::Management::Common

          def create_jwt_template(template: nil)
            # Create a new JWT template.
            # Args:
            # template (dict): the JWT template dict with format
            #       {
            #           "name": "name-of-template",
            #           "description": "description of the template",
            #           "template": "the template body",
            #           "conformanceIssuer": True|False,
            #           "authSchema": "one of default|tenantOnly|none"
            #       }
            post(JWT_TEMPLATE_CREATE_PATH, { template: })
          end

          def update_jwt_template(template: nil)
            # Update an existing JWT template.
            # The given template must include an "id" field.
            post(JWT_TEMPLATE_UPDATE_PATH, { template: })
          end

          def delete_jwt_template(id: nil)
            # Delete the JWT template with the given id.
            post(JWT_TEMPLATE_DELETE_PATH, { id: })
          end

          def list_jwt_templates
            # Load all JWT templates for the project.
            post(JWT_TEMPLATE_LIST_PATH, {})
          end

          def load_jwt_template(id: nil)
            # Load the JWT template with the given id.
            post(JWT_TEMPLATE_LOAD_PATH, { id: })
          end
        end
      end
    end
  end
end
