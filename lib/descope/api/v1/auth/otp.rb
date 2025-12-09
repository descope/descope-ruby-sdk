# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module OTP
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def otp_sign_in(method: nil, login_id: nil, login_options: nil, refresh_token: nil, provider_id: nil,
                          template_id: nil, sso_app_id: nil)
            # Sign in (log in) an existing user with the unique login_id you provide.
            # The login_id field is used to identify the user. It can be an email address or a phone number.
            # Provide the DeliveryMethod required for this user. If the login_id value cannot be used for the
            # DeliverMethod selected (for example, 'login_id = 4567qq445km' and 'DeliveryMethod = email')
            validate_login_id(login_id)
            uri = otp_compose_signin_url(method)
            body = otp_compose_signin_body(login_id, login_options, provider_id, template_id, sso_app_id)
            res = post(uri, body, {}, refresh_token)
            extract_masked_address(res, method)
          end

          def otp_sign_up(method: nil, login_id: nil, user: {}, provider_id: nil, template_id: nil)
            #  Sign up (create) a new user using their email or phone number.
            #  The login_id field is used to identify the user. It can be an email address or a phone number.
            #  Choose a delivery method for OTP verification, for example email, SMS, or Voice.
            #  (optional) Include additional user metadata that you wish to preserve.
            validate_login_id(login_id)

            unless adjust_and_verify_delivery_method(method, login_id, user)
              raise Descope::AuthException.new('Could not verify delivery method', code: 400)
            end

            uri = otp_compose_signup_url(method)
            body = otp_compose_signup_body(method, login_id, user, provider_id, template_id)
            res = post(uri, body)
            extract_masked_address(res, method)
          end

          def otp_sign_up_or_in(method: nil, login_id: nil, login_options: nil, provider_id: nil, template_id: nil,
                                sso_app_id: nil)
            #  Sign_up_or_in lets you handle both sign up and sign in with a single call.
            #  The login_id field is used to identify the user. It can be an email address or a phone number.
            #  Sign-up_or_in will first determine if login_id is a new or existing end user.
            #  If login_id is new, a new end user user will be created and then authenticated using the
            #  OTP DeliveryMethod specified.
            #  If login_id exists, the end user will be authenticated using the OTP DeliveryMethod specified.
            validate_login_id(login_id)
            uri = otp_compose_sign_up_or_in_url(method)
            body = otp_compose_signin_body(login_id, login_options, provider_id, template_id, sso_app_id)
            res = post(uri, body)
            extract_masked_address(res, method)
          end

          def otp_verify_code(method: nil, login_id: nil, code: nil)
            validate_login_id(login_id)
            uri = otp_compose_verify_code_url(method)
            request_params = {
              loginId: login_id,
              code:
            }
            res = post(uri, request_params)
            cookies = res.fetch(COOKIE_DATA_NAME, nil) || res.fetch('cookies', {})
            refresh_cookie = cookies.fetch(REFRESH_SESSION_COOKIE_NAME, nil) || res.fetch('refreshJwt', nil)
            generate_jwt_response(response_body: res, refresh_cookie:)
          end

          def otp_update_user_email(login_id: nil, email: nil, refresh_token: nil, add_to_login_ids: false,
                                    on_merge_use_existing: false, provider_id: nil, template_id: nil)
            # Update the email address of an end user, after verifying the authenticity of the end user using OTP.
            validate_login_id(login_id)
            validate_email(email)
            request_params = {
              loginId: login_id,
              email:,
              addToLoginIDs: add_to_login_ids,
              onMergeUseExisting: on_merge_use_existing
            }
            request_params[:providerId] = provider_id if provider_id
            request_params[:templateId] = template_id if template_id
            res = post(UPDATE_USER_EMAIL_OTP_PATH, request_params, {}, refresh_token)
            extract_masked_address(res, DeliveryMethod::EMAIL)
          end

          def otp_update_user_phone(
            method: nil, login_id: nil, phone: nil, refresh_token: nil, add_to_login_ids: false,
            on_merge_use_existing: false, provider_id: nil, template_id: nil
          )
            # Update the phone number of an existing end user, after verifying the authenticity of the end user using OTP
            validate_login_id(login_id)
            validate_phone(method, phone)

            uri = otp_compose_update_phone_url(method)
            request_params = {
              loginId: login_id,
              phone:,
              addToLoginIDs: add_to_login_ids,
              onMergeUseExisting: on_merge_use_existing
            }
            request_params[:providerId] = provider_id if provider_id
            request_params[:templateId] = template_id if template_id
            res = post(uri, request_params, {}, refresh_token)
            extract_masked_address(res, method)
          end

          private

          def otp_compose_signin_url(method = nil)
            method = Descope::Mixins::Common::DeliveryMethod::EMAIL if method.nil?
            compose_url(SIGN_IN_AUTH_OTP_PATH, method)
          end

          def otp_compose_signup_url(method = nil)
            method = Descope::Mixins::Common::DeliveryMethod::EMAIL if method.nil?
            compose_url(SIGN_UP_AUTH_OTP_PATH, method)
          end

          def otp_compose_sign_up_or_in_url(method = nil)
            method = Descope::Mixins::Common::DeliveryMethod::EMAIL if method.nil?
            compose_url(SIGN_UP_OR_IN_AUTH_OTP_PATH, method)
          end

          def otp_compose_verify_code_url(method = nil)
            method = Descope::Mixins::Common::DeliveryMethod::EMAIL if method.nil?
            compose_url(VERIFY_CODE_AUTH_PATH, method)
          end

          def otp_compose_update_phone_url(method = nil)
            method = Descope::Mixins::Common::DeliveryMethod::SMS if method.nil?
            compose_url(UPDATE_USER_PHONE_OTP_PATH, method)
          end

          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def otp_compose_signup_body(method, login_id, user, provider_id, template_id)
            body = {
              loginId: login_id
            }

            unless user.nil?
              body[:user] = otp_user_compose_update_body(**user) unless user.empty?
              method_str, val = get_login_id_by_method(method:, user:)
              body[method_str.to_sym] = val
            end

            body[:provider_id] = provider_id if provider_id
            body[:template_id] = template_id if template_id

            body
          end

          def otp_compose_signin_body(login_id, login_options, provider_id, template_id, sso_app_id)
            login_options ||= {}
            unless login_options.is_a?(Hash)
              raise Descope::ArgumentException.new(
                'Unable to read login_option, not a Hash',
                code: 400
              )
            end

            body = {
              loginId: login_id,
              loginOptions: {}
            }
            body[:providerId] = provider_id if provider_id
            body[:templateId] = template_id if template_id
            body[:ssoAppId] = sso_app_id if sso_app_id
            body[:loginOptions][:stepup] = login_options.fetch(:stepup, false)
            body[:loginOptions][:mfa] = login_options.fetch(:mfa, false)
            body[:loginOptions][:customClaims] = login_options.fetch(:custom_claims, {})
            body[:loginOptions][:ssoAppId] = login_options.fetch(:sso_app_id, nil)

            body
          end

          private
          def otp_user_compose_update_body(login_id: nil, name: nil, phone: nil, email: nil, given_name: nil,
                                           middle_name: nil, family_name: nil)
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
