# frozen_string_literal: true
module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module Password
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def password_sign_up(login_id: nil, password: nil, user: nil)
            # Sign up (create) a new user using a login ID and password.
            # (optional) Include additional user metadata that you wish to save.
            validate_login_id(login_id)
            validate_password(password)
            request_params = {
              loginId: login_id,
              password: password
            }
            request_params[:user] = user unless user.nil?

            post(SIGN_UP_PASSWORD_PATH, request_params)
          end

          def password_sign_in(login_id: nil, password: nil, sso_app_id: nil)
            # Sign-In an existing user utilizing password authentication. This endpoint will return the user's JWT..
            # Return dict in the format
            #  {"jwts": [], "user": "", "firstSeen": "", "error": ""}
            # Includes all the jwts tokens (session token, refresh token), token claims, and user information
            validate_login_id(login_id)
            validate_password(password)
            request_params = {
              loginId: login_id,
              password: password,
              ssoAppId: sso_app_id
            }
            res = post(SIGN_IN_PASSWORD_PATH, request_params)
            generate_jwt_response(response_body: res)
          end
        end
      end
    end
  end
end
