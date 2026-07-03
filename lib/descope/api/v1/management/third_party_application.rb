# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for third party applications
        module ThirdPartyApplication
          include Descope::Api::V1::Management::Common

          def create_application(
            name: nil,
            id: nil,
            description: nil,
            logo: nil,
            login_page_url: nil,
            approved_callback_urls: nil,
            permissions_scopes: nil,
            attributes_scopes: nil,
            jwt_bearer_settings: nil,
            custom_attributes: nil,
            force_pkce: nil,
            default_audience: nil
          )
            # Create a new third party application with the given name. Application IDs are provisioned automatically,
            # but can be provided explicitly if needed. Both the name and ID must be unique per project.
            body = compose_create_update_body(
              name:,
              id:,
              description:,
              logo:,
              login_page_url:,
              approved_callback_urls:,
              permissions_scopes:,
              attributes_scopes:,
              jwt_bearer_settings:,
              custom_attributes:,
              force_pkce:,
              default_audience:
            )
            post(THIRD_PARTY_APP_CREATE_PATH, body)
          end

          def update_application(
            id: nil,
            name: nil,
            description: nil,
            logo: nil,
            login_page_url: nil,
            approved_callback_urls: nil,
            permissions_scopes: nil,
            attributes_scopes: nil,
            jwt_bearer_settings: nil,
            custom_attributes: nil,
            force_pkce: nil,
            default_audience: nil
          )
            # Update an existing third party application with the given parameters. IMPORTANT: All parameters are used as
            # overrides to the existing application. Empty fields will override populated fields. Use carefully.
            body = compose_create_update_body(
              name:,
              id:,
              description:,
              logo:,
              login_page_url:,
              approved_callback_urls:,
              permissions_scopes:,
              attributes_scopes:,
              jwt_bearer_settings:,
              custom_attributes:,
              force_pkce:,
              default_audience:
            )
            post(THIRD_PARTY_APP_UPDATE_PATH, body)
          end

          def patch_application(
            id: nil,
            name: nil,
            description: nil,
            logo: nil,
            login_page_url: nil,
            approved_callback_urls: nil,
            permissions_scopes: nil,
            attributes_scopes: nil,
            jwt_bearer_settings: nil,
            custom_attributes: nil,
            force_pkce: nil,
            default_audience: nil
          )
            # Patch an existing third party application. Only the provided fields will be updated.
            body = compose_create_update_body(
              name:,
              id:,
              description:,
              logo:,
              login_page_url:,
              approved_callback_urls:,
              permissions_scopes:,
              attributes_scopes:,
              jwt_bearer_settings:,
              custom_attributes:,
              force_pkce:,
              default_audience:
            )
            post(THIRD_PARTY_APP_PATCH_PATH, body)
          end

          def delete_application(id)
            # Delete an existing third party application. IMPORTANT: This operation is irreversible. Use carefully.
            post(THIRD_PARTY_APP_DELETE_PATH, { id: })
          end

          def load_application(id)
            # Load an existing third party application.
            get(THIRD_PARTY_APP_LOAD_PATH, { id: })
          end

          def load_all_applications
            # Load all third party applications.
            get(THIRD_PARTY_APP_LOAD_ALL_PATH, {})
          end

          def get_application_secret(id)
            # Get the cleartext secret of an existing third party application.
            get(THIRD_PARTY_APP_SECRET_PATH, { id: })
          end

          def rotate_application_secret(id)
            # Rotate the secret of an existing third party application, returning the new cleartext secret.
            post(THIRD_PARTY_APP_ROTATE_PATH, { id: })
          end

          def delete_consents(app_id: nil, consent_ids: nil, user_ids: nil, tenant_id: nil)
            # Delete consents of a third party application.
            body = {}
            body[:consentIds] = consent_ids if consent_ids
            body[:appId] = app_id if app_id
            body[:userIds] = user_ids if user_ids
            body[:tenantId] = tenant_id if tenant_id
            post(THIRD_PARTY_APP_DELETE_CONSENTS_PATH, body)
          end

          def delete_tenant_consents(app_id: nil, consent_ids: nil, tenant_id: nil)
            # Delete consents of a third party application for a specific tenant.
            body = {}
            body[:consentIds] = consent_ids if consent_ids
            body[:appId] = app_id if app_id
            body[:tenantId] = tenant_id if tenant_id
            post(THIRD_PARTY_APP_DELETE_TENANT_CONSENTS_PATH, body)
          end

          private

          # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def compose_create_update_body(
            name: nil,
            id: nil,
            description: nil,
            logo: nil,
            login_page_url: nil,
            approved_callback_urls: nil,
            permissions_scopes: nil,
            attributes_scopes: nil,
            jwt_bearer_settings: nil,
            custom_attributes: nil,
            force_pkce: nil,
            default_audience: nil
          )
            body = {}
            body[:id] = id if id
            body[:name] = name if name
            body[:description] = description if description
            body[:logo] = logo if logo
            body[:loginPageUrl] = login_page_url if login_page_url
            body[:approvedCallbackUrls] = approved_callback_urls if approved_callback_urls
            body[:permissionsScopes] = permissions_scopes if permissions_scopes
            body[:attributesScopes] = attributes_scopes if attributes_scopes
            body[:jwtBearerSettings] = jwt_bearer_settings if jwt_bearer_settings
            body[:customAttributes] = custom_attributes if custom_attributes
            body[:forcePkce] = force_pkce unless force_pkce.nil?
            body[:defaultAudience] = default_audience if default_audience
            body
          end
          # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        end
      end
    end
  end
end
