# frozen_string_literal: true
# https://github.com/descope/go-sdk/pull/429/files
module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module NOTP
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def get_notp_response(response_body)
            pass
          end

          def notp_get_session(pending_ref = nil)
            raise Descope::ArgumentException.new('Pending reference is required', code: 400) if pending_ref.nil?

            res = post(notp_compose_get_session, { pendingReference: pending_ref })
            get_notp_response(res)
          end

          def notp_sign_in(login_id: nil, login_options: nil, refresh_token: nil)
            validate_login_id(login_id)
            uri = notp_compose_signin_url
            body = notp_compose_signin_body(login_id, login_options)
            res = post(uri, body, {}, refresh_token)
            extract_masked_address(res, method)
          end

          def notp_sign_up(login_id: nil, user: {}, signup_options: nil)
            validate_login_id(login_id)

            user['Phone'] = login_id if user['phone'].nil?
            uri = notp_compose_signup_url
            body = notp_compose_signup_body(login_id, user, signup_options)
            res = post(uri, body)
            extract_masked_address(res, method)
          end

          def notp_sign_up_or_in(login_id: nil, login_options: nil, signup_options: nil)
            validate_login_id(login_id)
            uri = notp_compose_sign_up_or_in_url
            body = notp_compose_signin_body(login_id, login_options, signup_options)
            res = post(uri, body)
            extract_masked_address(res)
          end
          

          def notp_update_user_email(login_id: nil, email: nil, refresh_token: nil, add_to_login_ids: false,
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

            uri = notp_compose_update_phone_url(method)
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

          def notp_compose_signin_url
            compose_url(SIGN_IN_AUTH_NOTP_PATH, Descope::Mixins::Common::DeliveryMethod::WHATSAPP)
          end

          def notp_compose_signup_url
            compose_url(SIGN_UP_AUTH_NOTP_PATH, Descope::Mixins::Common::DeliveryMethod::WHATSAPP)
          end

          def notp_compose_sign_up_or_in_url
            compose_url(SIGN_UP_OR_IN_AUTH_NOTP_PATH, Descope::Mixins::Common::DeliveryMethod::WHATSAPP)
          end

          def notp_compose_get_session
            compose_url(GET_NOTP_SESSION_PATH, Descope::Mixins::Common::DeliveryMethod::WHATSAPP)
          end

          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def notp_compose_signup_body(method, login_id, user, provider_id, template_id)
            body = {
              loginId: login_id
            }

            unless user.nil?
              body[:user] = notp_user_compose_update_body(**user) unless user.empty?
              method_str, val = get_login_id_by_method(method:, user:)
              body[method_str.to_sym] = val
            end

            body[:provider_id] = provider_id if provider_id
            body[:template_id] = template_id if template_id

            body
          end

          def notp_compose_signin_body(login_id, login_options, provider_id, template_id, sso_app_id)
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
          def notp_user_compose_update_body(login_id: nil, name: nil, phone: nil, email: nil, given_name: nil,
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
