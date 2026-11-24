# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module SSOSettings
          include Descope::Api::V1::Management::Common

          def get_sso_settings(tenant_id)
            # Get SSO settings for the provided tenant id.
            # For SAML, the response's saml.acceptedAudiences lists the audience values a SAML assertion
            # may carry in place of the tenant's SP entity ID.
            mgmt_get(SSO_SETTINGS_PATH, { tenantId: tenant_id })
          end

          def delete_sso_settings(tenant_id)
            # Delete SSO settings for the provided tenant id.
            mgmt_delete(SSO_SETTINGS_PATH, { tenantId: tenant_id })
          end

          def configure_sso_oidc(tenant_id: nil, settings: nil, redirect_url: nil, domain: nil)
            raise Descope::ArgumentException.new('SSO settings must be a Hash', code: 400) unless settings.is_a?(Hash)

            # Configure tenant SSO OIDC Settings, using a valid management key.
            request_params = {
              tenantId: tenant_id,
              settings: compose_settings_body(settings),
              redirectUrl: redirect_url,
              domain:
            }
            mgmt_post(SSO_OIDC_PATH, request_params)
          end

          def configure_sso_saml(tenant_id: nil, settings: nil, redirect_url: nil, domain: nil, domains: nil,
                                 accepted_audiences: nil)
            raise Descope::ArgumentException.new('SSO SAML settings must be a Hash', code: 400) unless settings.is_a?(Hash)

            # Configure tenant SSO SAML Settings manually, using a valid management key.
            # settings takes snake_case keys. idp_url, idp_entity_id and idp_cert are required. Optional keys:
            # idp_additional_certs, attribute_mapping (name, email, phone_number, group, given_name, middle_name,
            # family_name, picture, custom_attributes), role_mappings (a list of { groups:, role_name: }),
            # default_sso_roles (an empty list clears them), groups_priority, fga_mappings,
            # config_fga_tenant_id_resource_prefix, config_fga_tenant_id_resource_suffix, disable_sign_request,
            # authentication_only, jit_disabled, and sp_acs_url / sp_entity_id (set these only when migrating SSO).
            # The settings replace the stored ones, except authentication_only and jit_disabled, which keep the
            # stored value when left out.
            # domain is a single domain and domains a list of them; both are sent together and replace the
            # stored domains, so leaving both out clears them.
            # accepted_audiences is an optional list of audience values a SAML assertion may carry in place of
            # the tenant's SP entity ID, for IdPs that send a different audience. Values must match exactly
            # (surrounding whitespace is ignored) and an empty string accepts an empty audience. Up to 20 values
            # of up to 1000 characters each. Leave it nil to keep the stored values. Pass an array to replace
            # them, or an empty array to clear them.
            settings_body = compose_saml_settings_body(settings, SAML_SETTINGS_KEYS, accepted_audiences)
            mgmt_post(SSO_CONFIGURE_SAML_SETTINGS_PATH,
                      compose_saml_request(tenant_id, settings_body, redirect_url, domain, domains))
          end

          def configure_sso_saml_metadata(tenant_id: nil, settings: nil, redirect_url: nil, domain: nil, domains: nil,
                                          accepted_audiences: nil)
            unless settings.is_a?(Hash)
              raise Descope::ArgumentException.new('SSO SAML settings must be a Hash', code: 400)
            end

            # Configure tenant SSO SAML Settings from the IdP metadata URL, using a valid management key.
            # settings takes the same keys as configure_sso_saml, except that idp_metadata_url (required)
            # replaces idp_url, idp_cert and idp_additional_certs, and idp_entity_id is optional.
            # domain, domains and accepted_audiences work the same as in configure_sso_saml: for
            # accepted_audiences, nil keeps the stored values, an array replaces them and an empty array clears them.
            settings_body = compose_saml_settings_body(settings, SAML_METADATA_SETTINGS_KEYS, accepted_audiences)
            mgmt_post(SSO_CONFIGURE_SAML_METADATA_PATH,
                      compose_saml_request(tenant_id, settings_body, redirect_url, domain, domains))
          end

          # SAML settings keys and the API fields they map to. attribute_mapping, role_mappings and
          # fga_mappings are nested and mapped separately.
          SAML_COMMON_SETTINGS_KEYS = {
            idp_entity_id: :entityId,
            default_sso_roles: :defaultSSORoles,
            groups_priority: :groupsPriority,
            config_fga_tenant_id_resource_prefix: :configFGATenantIDResourcePrefix,
            config_fga_tenant_id_resource_suffix: :configFGATenantIDResourceSuffix,
            disable_sign_request: :disableSignRequest,
            authentication_only: :authenticationOnly,
            jit_disabled: :jitDisabled,
            sp_acs_url: :spACSUrl,
            sp_entity_id: :spEntityId
          }.freeze
          SAML_SETTINGS_KEYS = {
            idp_url: :idpUrl,
            idp_cert: :idpCert,
            idp_additional_certs: :idpAdditionalCerts
          }.merge(SAML_COMMON_SETTINGS_KEYS).freeze
          SAML_METADATA_SETTINGS_KEYS = { idp_metadata_url: :idpMetadataUrl }.merge(SAML_COMMON_SETTINGS_KEYS).freeze
          private_constant :SAML_COMMON_SETTINGS_KEYS, :SAML_SETTINGS_KEYS, :SAML_METADATA_SETTINGS_KEYS

          private

          # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def compose_settings_body(settings)

            body = {}
            body[:name] = settings[:name] if settings.key?(:name)
            body[:clientId] = settings[:client_id] if settings.key?(:client_id)
            body[:clientSecret] = settings[:client_secret] if settings.key?(:client_secret)
            body[:redirectUrl] = settings[:redirect_url] if settings.key?(:redirect_url)
            body[:authUrl] = settings[:auth_url] if settings.key?(:auth_url)
            body[:tokenUrl] = settings[:token_url] if settings.key?(:token_url)
            body[:userDataUrl] = settings[:user_data_url] if settings.key?(:user_data_url)
            body[:scope] = settings[:scope] if settings.key?(:scope)
            body[:JWKsUrl] = settings[:jwks_url] if settings.key?(:jwks_url)
            user_mappings = settings[:user_attr_mapping] if settings.key?(:user_attr_mapping)

            # rubocop:disable Metrics/LineLength
            unless user_mappings.nil? || user_mappings.empty?
              body[:userAttrMapping] = {}
              body[:userAttrMapping][:loginId] = user_mappings[:login_id] if settings[:user_attr_mapping].key?(:login_id)
              body[:userAttrMapping][:username] = user_mappings[:username] if settings[:user_attr_mapping].key?(:username)
              body[:userAttrMapping][:name] = user_mappings[:name] if settings[:user_attr_mapping].key?(:name)
              body[:userAttrMapping][:email] = user_mappings[:email] if settings[:user_attr_mapping].key?(:email)
              body[:userAttrMapping][:phoneNumber] = user_mappings[:phone_number] if settings[:user_attr_mapping].key?(:phone_number)
              body[:userAttrMapping][:verifiedEmail] = user_mappings[:verified_email] if settings[:user_attr_mapping].key?(:verified_email)
              body[:userAttrMapping][:verifiedPhone] = user_mappings[:verified_phone] if settings[:user_attr_mapping].key?(:verified_phone)
              body[:userAttrMapping][:picture] = user_mappings[:picture] if settings[:user_attr_mapping].key?(:picture)
              body[:userAttrMapping][:givenName] = user_mappings[:given_name] if settings[:user_attr_mapping].key?(:given_name)
              body[:userAttrMapping][:middleName] = user_mappings[:middle_name] if settings[:user_attr_mapping].key?(:middle_name)
              body[:userAttrMapping][:familyName] = user_mappings[:family_name] if settings[:user_attr_mapping].key?(:family_name)
            end

            body[:manageProviderTokens] = settings[:manage_provider_tokens] if settings.key?(:manage_provider_tokens)
            body[:callbackDomain] = settings[:callback_domain] if settings.key?(:callback_domain)
            body[:prompt] = settings[:prompt] if settings.key?(:prompt)
            body[:grantType] = settings[:grant_type] if settings.key?(:grant_type)
            body[:issuer] = settings[:issuer] if settings.key?(:issuer)

            body
          end

          def compose_saml_request(tenant_id, settings_body, redirect_url, domain, domains)
            saml_domains = Array(domains)
            saml_domains += [domain] unless domain.nil?
            {
              tenantId: tenant_id,
              settings: settings_body,
              redirectUrl: redirect_url,
              domains: saml_domains.uniq
            }
          end

          def compose_saml_settings_body(settings, keys, accepted_audiences)
            body = {}
            keys.each { |key, field| body[field] = settings[key] if settings.key?(key) }
            attribute_mapping, role_mappings, fga_mappings = settings.values_at(:attribute_mapping, :role_mappings,
                                                                                :fga_mappings)
            body[:attributeMapping] = attribute_mapping_to_hash(attribute_mapping) unless attribute_mapping.nil?
            body[:roleMappings] = role_mapping_to_hash(role_mappings) unless role_mappings.nil?
            body[:fgaMappings] = fga_mappings_to_hash(fga_mappings) unless fga_mappings.nil?
            # An empty list can't be told apart from a missing one once sent, so clearing the default SSO roles
            # also needs the replace flag.
            body[:replaceDefaultSSORoles] = true if settings[:default_sso_roles] == []
            add_accepted_audiences(body, accepted_audiences)
          end

          # nil keeps the stored accepted audiences, so neither field is sent. An array (empty included)
          # replaces them, so the list is sent together with the replace flag.
          def add_accepted_audiences(settings_body, accepted_audiences)
            return settings_body if accepted_audiences.nil?

            settings_body[:acceptedAudiences] = accepted_audiences
            settings_body[:replaceAcceptedAudiences] = true
            settings_body
          end

          def role_mapping_to_hash(role_mapping)
            role_mapping ||= []
            role_mapping_list = []
            role_mapping.each do |mapping|
              role_mapping_list << {
                groups: mapping[:groups],
                roleName: mapping[:role_name]
              }
            end
            role_mapping_list
          end

          def attribute_mapping_to_hash(attribute_mapping)
            if attribute_mapping.nil?
              raise Descope::ArgumentException.new('SSO Attribute mapping cannot be None', code: 400)
            end

            {
              name: attribute_mapping[:name],
              email: attribute_mapping[:email],
              phoneNumber: attribute_mapping[:phone_number],
              group: attribute_mapping[:group],
              givenName: attribute_mapping[:given_name],
              middleName: attribute_mapping[:middle_name],
              familyName: attribute_mapping[:family_name],
              picture: attribute_mapping[:picture],
              customAttributes: attribute_mapping[:custom_attributes]
            }.compact
          end

          # fga_mappings maps an IdP group name to { relations: [{ resource:, relation_definition:, namespace: }] }.
          def fga_mappings_to_hash(fga_mappings)
            fga_mappings.to_h do |group, mapping|
              relations = (mapping || {})[:relations] || []
              [group, {
                relations: relations.map do |relation|
                  {
                    resource: relation[:resource],
                    relationDefinition: relation[:relation_definition],
                    namespace: relation[:namespace]
                  }
                end
              }]
            end
          end
        end
      end
    end
  end
end
