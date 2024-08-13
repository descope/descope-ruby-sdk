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
            get(SSO_SETTINGS_PATH, { tenantId: tenant_id })
          end

          def delete_sso_settings(tenant_id)
            # Delete SSO settings for the provided tenant id.
            delete(SSO_SETTINGS_PATH, { tenantId: tenant_id })
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
            post(SSO_OIDC_PATH, request_params)
          end

          def configure_sso_saml(tenant_id: nil, settings: nil, redirect_url: nil, domain: nil)
            raise Descope::ArgumentException.new('SSO SAML settings must be a Hash', code: 400) unless settings.is_a?(Hash)

            # Configure tenant SSO SAML Settings, using a valid management key.
            request_params = {
              tenantId: tenant_id,
              settings: compose_settings_body(settings),
              redirectUrl: redirect_url,
              domain:
            }
            post(SSO_SETTINGS_PATH, request_params)
          end

          def configure_sso_saml_metadata(tenant_id: nil, settings: nil, redirect_url: nil, domain: nil)
            # Configure tenant SSO SAML Metadata, using a valid management key.
            post(SSO_METADATA_PATH, compose_metadata_body(tenant_id, settings, redirect_url, domain))
          end

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

          def compose_metadata_body(tenant_id, settings, redirect_url, domain)
            {
              tenantId: tenant_id,
              settings: compose_settings_body(settings),
              redirectUrl: redirect_url,
              domain:
            }
          end

          def role_mapping_to_hash(role_mapping)
            role_mapping ||= []
            role_mapping_list = []
            role_mapping.each do |mapping|
              role_mapping_list << {
                groups: mapping['groups'],
                roleName: mapping['role_name']
              }
            end
            role_mapping_list
          end

          def attribute_mapping_to_hash(attribute_mapping)
            if attribute_mapping.nil?
              raise Descope::ArgumentException.new('SSO Attribute mapping cannot be None', code: 400)
            end

            {
              name: attribute_mapping['name'],
              email: attribute_mapping['email'],
              phoneNumber: attribute_mapping['phone_number'],
              groups: attribute_mapping['groups']
            }
          end
        end
      end
    end
  end
end
