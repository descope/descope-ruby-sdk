# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module TOTP
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def totp_sign_in_code(login_id: nil, login_options: nil, code: nil)
            # Sign in by verifying the validity of a TOTP code entered by an end user.
            validate_login_id(login_id)
            validate_code(code)
            uri = VERIFY_TOTP_PATH
            body = totp_compose_signin_body(login_id, code, login_options)
            res = post(uri, body, {}, nil)
            cookies = res.fetch(COOKIE_DATA_NAME, nil) || res.fetch('cookies', {})
            refresh_cookie = cookies.fetch(REFRESH_SESSION_COOKIE_NAME, nil) || res.fetch('refreshJwt', nil)
            generate_jwt_response(response_body: res, refresh_cookie:)
          end

          def totp_sign_up(login_id: nil, user: nil, sso_app_id: nil)
            # Sign up (create) a new user using their email or phone number.
            # (optional) Include additional user metadata that you wish to save.
            user ||= {}
            validate_login_id(login_id)

            request_params = {
              loginId: login_id
            }
            request_params[:user] = user_compose_update_body(**user) unless user.empty?
            request_params[:ssoAppId] = sso_app_id unless sso_app_id.nil?
            post(SIGN_UP_AUTH_TOTP_PATH, request_params)
          end

          def totp_add_update_key(login_id: nil, refresh_token: nil)
            # Add or update TOTP key for existing end userUpdate the email address of an end user,
            # after verifying the authenticity of the end user using OTP.
            validate_login_id(login_id)
            post(UPDATE_TOTP_PATH, { loginId: login_id }, {}, refresh_token)
          end

          private

          # rubocop:disable Metrics/MethodLength
          def totp_compose_signin_body(login_id, code, login_options)
            login_options ||= {}
            unless login_options.is_a?(Hash)
              raise Descope::ArgumentException.new(
                'Unable to read login_option, not a Hash',
                code: 400
              )
            end

            body = {
              loginId: login_id,
              code:,
              loginOptions: {}
            }
            body[:loginOptions][:stepup] = login_options.fetch(:stepup, false)
            body[:loginOptions][:mfa] = login_options.fetch(:mfa, false)
            body[:loginOptions][:customClaims] = login_options.fetch(:custom_claims, {})
            body[:loginOptions][:ssoAppId] = login_options.fetch(:sso_app_id, nil)

            body
          end
        end
      end
    end
  end
end
