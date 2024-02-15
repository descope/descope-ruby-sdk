# frozen_string_literal: true

require 'cgi'

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module SAML
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          # rubocop:disable Metrics/AbcSize
          def saml_sign_in(tenant: nil, redirect_url: nil, prompt: nil, stepup: false,
                           mfa: false, custom_claims: {}, sso_app_id: nil)
            validate_tenant(tenant)
            validate_redirect_url(redirect_url)
            uri = compose_saml_signin_url(tenant, redirect_url, prompt)

            request_params = {}
            request_params[:stepup] = stepup
            request_params[:mfa] = mfa
            request_params[:customClaims] = custom_claims
            request_params[:ssoAppId] = sso_app_id unless sso_app_id.nil?

            post(uri, request_params)
          end

          def saml_exchange_token(code = nil)
            exchange_token(SAML_EXCHANGE_TOKEN_PATH, code)
          end

          private

          def compose_saml_signin_url(tenant, redirect_url, prompt)
            uri = AUTH_SAML_START_PATH
            uri += "?tenant=#{CGI.escape(tenant)}" unless tenant.nil?
            uri += "&redirectUrl=#{CGI.escape(redirect_url)}" unless redirect_url.nil?
            uri += "&prompt=#{CGI.escape(prompt)}" unless prompt.nil?
            uri
          end
        end
      end
    end
  end
end
