# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module SSOApplication
          include Descope::Api::V1::Management::Common

          def create_sso_oidc_app(id: nil, name: nil, description: nil, enabled: nil, logo: nil, login_page_url: nil)
            # Create a new OIDC sso application with the given name. SSO application IDs are provisioned automatically,
            # but can be provided explicitly if needed. Both the name and ID must be unique per project.
            body = {}
            body[:id] = id if id
            body[:name] = name if name
            body[:description] = description if description
            body[:enabled] = enabled if enabled
            body[:logo] = logo if logo
            body[:loginPageUrl] = login_page_url if login_page_url
            post(SSO_APPLICATION_OIDC_CREATE_PATH, body)
          end

          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def create_saml_application(
            name: nil,
            login_page_url: nil,
            id: nil,
            description: nil,
            logo: nil,
            enabled: nil,
            use_metadata_info: nil,
            metadata_url: nil,
            entity_id: nil,
            acs_url: nil,
            certificate: nil,
            attribute_mapping: nil,
            groups_mapping: nil,
            acs_allowed_callbacks: nil,
            subject_name_id_type: nil,
            subject_name_id_format: nil,
            default_relay_state: nil,
            force_authentication: nil,
            logout_redirect_url: nil
          )
            # Create a new SAML sso application with the given name. SSO application IDs are provisioned automatically,
            # but can be provided explicitly if needed. Both the name and ID must be unique per project.

            if use_metadata_info
              raise 'metadata_url argument must be set' unless metadata_url
            else
              raise 'entity_id, acs_url, certificate arguments must be set' unless entity_id && acs_url && certificate
            end

            attribute_mapping ||= []
            groups_mapping ||= []
            acs_allowed_callbacks ||= []
            body = compose_create_update_saml_body(
              name:,
              login_page_url:,
              id:,
              description:,
              enabled:,
              logo:,
              use_metadata_info:,
              metadata_url:,
              entity_id:,
              acs_url:,
              certificate:,
              attribute_mapping:,
              groups_mapping:,
              acs_allowed_callbacks:,
              subject_name_id_type:,
              subject_name_id_format:,
              default_relay_state:,
              force_authentication:,
              logout_redirect_url:
            )
            post(SSO_APPLICATION_SAML_CREATE_PATH, body)
          end

          def update_sso_oidc_app(id: nil, name: nil, description: nil, enabled: nil, logo: nil, login_page_url: nil, force_authentication: nil)
            # Update an existing OIDC sso application with the given parameters. IMPORTANT: All parameters are used as overrides
            # to the existing sso application. Empty fields will override populated fields. Use carefully.
            body = compose_create_update_oidc_body(name, login_page_url, id, description, enabled, logo, force_authentication)
            post(SSO_APPLICATION_OIDC_UPDATE_PATH, body)
          end

          def update_saml_application(
            id: nil,
            name: nil,
            login_page_url: nil,
            description: nil,
            logo: nil,
            enabled: nil,
            use_metadata_info: nil,
            metadata_url: nil,
            entity_id: nil,
            acs_url: nil,
            certificate: nil,
            attribute_mapping: nil,
            groups_mapping: nil,
            acs_allowed_callbacks: nil,
            subject_name_id_type: nil,
            subject_name_id_format: nil,
            default_relay_state: nil,
            force_authentication: nil,
            logout_redirect_url: nil
          )
            # Update an existing SAML sso application with the given parameters. IMPORTANT: All parameters are used as overrides
            # to the existing sso application. Empty fields will override populated fields. Use carefully.

            if use_metadata_info
              raise 'metadata_url argument must be set' unless metadata_url
            else
              raise 'entity_id, acs_url, certificate arguments must be set' unless entity_id && acs_url
            end

            attribute_mapping ||= []
            groups_mapping ||= []
            acs_allowed_callbacks ||= []

            body = compose_create_update_saml_body(
              name:,
              login_page_url:,
              id:,
              description:,
              enabled:,
              logo:,
              use_metadata_info:,
              metadata_url:,
              entity_id:,
              acs_url:,
              certificate:,
              attribute_mapping:,
              groups_mapping:,
              acs_allowed_callbacks:,
              subject_name_id_type:,
              subject_name_id_format:,
              default_relay_state:,
              force_authentication:,
              logout_redirect_url:
            )
            post(SSO_APPLICATION_SAML_UPDATE_PATH, body)
          end

          def delete_sso_app(id)
            # Delete an existing sso application. IMPORTANT: This operation is irreversible. Use carefully.
            delete(SSO_APPLICATION_DELETE_PATH, { id: })
          end

          def load_sso_app(id)
            # Load an existing sso application.
            get(SSO_APPLICATION_LOAD_PATH, { id: })
          end

          def load_all_sso_apps
            # Load all sso applications.
            #
            #   Return value:
            #        {
            #           "apps": [
            #                   {"id":"app1","name":"<name>","description":"<description>","enabled":true,"logo":"","appType":"saml","samlSettings":{"loginPageUrl":"","idpCert":"<cert>","useMetadataInfo":true,"metadataUrl":"","entityId":"","acsUrl":"","certificate":"","attributeMapping":[{"name":"email","type":"","value":"attrVal1"}],"groupsMapping":[{"name":"grp1","type":"","filterType":"roles","value":"","roles":[{"id":"myRoleId","name":"myRole"}]}],"idpMetadataUrl":"","idpEntityId":"","idpSsoUrl":"","acsAllowedCallbacks":[],"subjectNameIdType":"","subjectNameIdFormat":"", "defaultRelayState":"", "forceAuthentication": false, "idpLogoutUrl": "", "logoutRedirectUrl": ""},"oidcSettings":{"loginPageUrl":"","issuer":"","discoveryUrl":"", "forceAuthentication":false}},
            #           {"id":"app2","name":"<name>","description":"<description>","enabled":true,"logo":"","appType":"saml","samlSettings":{"loginPageUrl":"","idpCert":"<cert>","useMetadataInfo":true,"metadataUrl":"","entityId":"","acsUrl":"","certificate":"","attributeMapping":[{"name":"email","type":"","value":"attrVal1"}],"groupsMapping":[{"name":"grp1","type":"","filterType":"roles","value":"","roles":[{"id":"myRoleId","name":"myRole"}]}],"idpMetadataUrl":"","idpEntityId":"","idpSsoUrl":"","acsAllowedCallbacks":[],"subjectNameIdType":"","subjectNameIdFormat":"", "defaultRelayState":"", "forceAuthentication": false, "idpLogoutUrl": "", "logoutRedirectUrl": ""},"oidcSettings":{"loginPageUrl":"","issuer":"","discoveryUrl":"", "forceAuthentication":false}}
            #           ]
            #       }
            #   Containing the loaded sso applications information.
            get(SSO_APPLICATION_LOAD_ALL_PATH, {})
          end

          private

          def compose_create_update_oidc_body(name, login_page_url, id, description, enabled, logo, force_authentication)
            body = {}
            body[:name] = name if name
            body[:loginPageUrl] = login_page_url if login_page_url
            body[:id] = id if id
            body[:description] = description if description
            body[:logo] = logo if logo
            body[:enabled] = enabled if enabled
            body[:force_authentication] = force_authentication if force_authentication
            body
          end

          # rubocop:disable Metrics/AbcSize
          def compose_create_update_saml_body(
            name: nil,
            login_page_url: nil,
            id: nil,
            description: nil,
            enabled: nil,
            logo: nil,
            use_metadata_info: nil,
            metadata_url: nil,
            entity_id: nil,
            acs_url: nil,
            certificate: nil,
            attribute_mapping: nil,
            groups_mapping: nil,
            acs_allowed_callbacks: nil,
            subject_name_id_type: nil,
            subject_name_id_format: nil,
            default_relay_state: nil,
            force_authentication: nil,
            logout_redirect_url: nil
          )
            body = {}
            body[:name] = name if name
            body[:loginPageUrl] = login_page_url if login_page_url
            body[:id] = id if id
            body[:description] = description if description
            body[:enabled] = enabled if enabled
            body[:logo] = logo if logo
            body[:useMetadataInfo] = use_metadata_info if use_metadata_info
            body[:metadataUrl] = metadata_url if metadata_url
            body[:entityId] = entity_id if entity_id
            body[:acsUrl] = acs_url if acs_url
            body[:certificate] = certificate if certificate
            body[:attributeMapping] = attribute_mapping if attribute_mapping
            body[:groupsMapping] = groups_mapping if groups_mapping
            body[:acsAllowedCallbacks] = acs_allowed_callbacks if acs_allowed_callbacks
            body[:subjectNameIdType] = subject_name_id_type if subject_name_id_type
            body[:subjectNameIdFormat] = subject_name_id_format if subject_name_id_format
            body[:defaultRelayState] = default_relay_state if default_relay_state
            body[:forceAuthentication] = force_authentication if force_authentication
            body[:logoutRedirectUrl] = logout_redirect_url if logout_redirect_url
            puts "body: #{body}"
            body
          end
        end
      end
    end
  end
end
