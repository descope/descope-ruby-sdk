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
              password:
            }

            request_params[:user] = password_user_compose_update_body(**user) unless user.nil?
            res = post(SIGN_UP_PASSWORD_PATH, request_params)
            cookies = res.fetch(COOKIE_DATA_NAME, nil) || res.fetch('cookies', {})
            refresh_cookie = cookies.fetch(REFRESH_SESSION_COOKIE_NAME, nil) || res.fetch('refreshJwt', nil)
            generate_jwt_response(response_body: res, refresh_cookie:)
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
              password:,
              ssoAppId: sso_app_id
            }
            res = post(SIGN_IN_PASSWORD_PATH, request_params)
            cookies = res.fetch(COOKIE_DATA_NAME, nil) || res.fetch('cookies', {})
            refresh_cookie = cookies.fetch(REFRESH_SESSION_COOKIE_NAME, nil) || res.fetch('refreshJwt', nil)
            generate_jwt_response(response_body: res, refresh_cookie:)
          end

          def password_replace(login_id: nil, old_password: nil, new_password: nil)
            # Replace an existing user's password with a new password.
            validate_login_id(login_id)
            validate_password(old_password)
            validate_password(new_password)
            request_params = {
              loginId: login_id,
              oldPassword: old_password,
              newPassword: new_password
            }
            post(REPLACE_PASSWORD_PATH, request_params)
          end

          def password_update(login_id: nil, new_password: nil, refresh_token: nil)
            # Update an existing user's password with a new password.
            validate_login_id(login_id)
            validate_password(new_password)
            validate_refresh_token_not_nil(refresh_token)
            request_params = {
              loginId: login_id,
              newPassword: new_password
            }
            post(UPDATE_PASSWORD_PATH, request_params, {}, refresh_token)
          end

          def get_password_policy(refresh_token = nil)
            # Get the configured password policy for the project.
            get(PASSWORD_POLICY_PATH, {}, {}, refresh_token)
          end

          def password_reset(login_id: nil, redirect_url: nil, provider_id: nil, template_id: nil)
            #  Sends a password reset prompt to the user with the given
            #  login_id according to the password settings defined in the Descope console.
            # NOTE: The user must be verified according to the configured password reset method.
            validate_login_id(login_id)
            post(SEND_RESET_PASSWORD_PATH,
                 loginId: login_id, redirectUrl: redirect_url, providerId: provider_id, templateId: template_id)
          end

          private
          def password_user_compose_update_body(login_id: nil, name: nil, phone: nil, email: nil, given_name: nil, middle_name: nil, family_name: nil)
            user = {}
            user[:loginId] = login_id if login_id
            user[:name] = name if name
            user[:phone] = phone if phone
            user[:email] = email if email
            user[:givenName] = given_name if given_name
            user[:middleName] = middle_name if middle_name
            user[:familyName] = family_name if family_name

            user
          end
        end
      end
    end
  end
end
