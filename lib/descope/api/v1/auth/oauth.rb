# frozen_string_literal: true
require 'cgi'

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module OAuth
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def oauth_start(provider: nil, return_url: nil, prompt: nil, login_options: nil, refresh_token: nil, template_options: nil)
            body = compose_start_params(login_options:, template_options:)
            url = "#{OAUTH_START_PATH}?provider=#{provider}"
            url += "&redirectUrl=#{CGI.escape(return_url)}" if return_url
            url += "&prompt=#{CGI.escape(prompt)}" if prompt
            post(url, body, {}, refresh_token)
          end

          def oauth_exchange_token(code = nil)
            exchange_token(OAUTH_EXCHANGE_TOKEN_PATH, code)
          end

          def oauth_create_redirect_url_for_sign_in_request(stepup: false, custom_claims: {}, mfa: false,
                                                            sso_app_id: nil)
            request_params = {
              stepup:,
              customClaims: custom_claims,
              mfa:,
              ssoAppId: sso_app_id
            }
            post(OAUTH_CREATE_REDIRECT_URL_FOR_SIGN_IN_REQUEST_PATH, request_params)
          end

          def oauth_create_redirect_url_for_sign_up_request(stepup: false, custom_claims: {}, mfa: false,
                                                            sso_app_id: nil)
            request_params = {
              stepup:,
              customClaims: custom_claims,
              mfa:,
              ssoAppId: sso_app_id
            }
            post(OAUTH_CREATE_REDIRECT_URL_FOR_SIGN_UP_REQUEST_PATH, request_params)
          end

          private

          def compose_start_params(login_options: nil, template_options: nil)
            login_options ||= {}

            unless login_options.is_a?(Hash)
              raise Descope::ArgumentException.new(
                'Unable to read login_options, not a Hash',
                code: 400
              )
            end

            body = {}
            body[:stepup] = login_options.fetch(:stepup, false)
            body[:mfa] = login_options.fetch(:mfa, false)
            body[:customClaims] = login_options.fetch(:custom_claims, {})
            body[:ssoAppId] = login_options.fetch(:sso_app_id, nil) if login_options.key?(:sso_app_id)
            body[:templateOptions] = template_options unless template_options.nil?
            body
          end
        end
      end
    end
  end
end
