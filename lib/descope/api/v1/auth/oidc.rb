# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module OIDC
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def oidc_start(response_type: nil, scope: nil, client_id: nil, state: nil, redirect_url: nil,
                         code_challenge_method: nil, code_challenge: nil, dynamic_val: nil, nonce: nil,
                         sso_app_id: nil, login_hint: nil)
            # OIDC GET authorization endpoint start
            url = compose_oidc_start_url(
              response_type, scope, client_id,
              state, redirect_url, code_challenge_method, code_challenge,
              dynamic_val, nonce, sso_app_id, login_hint
            )

            get(url)
          end

          private

          def compose_oidc_start_url(response_type, scope, client_id,
                                       state, redirect_url, code_challenge_method,
                                       code_challenge, dynamic_val, nonce, sso_app_id, login_hint)
            url = "#{OAUTH2_START_PATH}?"
            url += "response_type=#{response_type}&" unless response_type.nil?
            url += "scope=#{scope}&" unless scope.nil?
            url += "client_id=#{client_id}&" unless client_id.nil?
            url += "state=#{state}&" unless state.nil?
            url += "redirect_url=#{redirect_url}&" unless redirect_url.nil?
            url += "code_challenge_method=#{code_challenge_method}&" unless code_challenge_method.nil?
            url += "code_challenge=#{code_challenge}&" unless code_challenge.nil?
            url += "dynamic_val=#{dynamic_val}&" unless dynamic_val.nil?
            url += "nonce=#{nonce}&" unless nonce.nil?
            url += "ssoAppId=#{sso_app_id}&" unless sso_app_id.nil?
            url += "loginHint=#{login_hint}&" unless login_hint.nil?
            url
          end
        end
      end
    end
  end
end
