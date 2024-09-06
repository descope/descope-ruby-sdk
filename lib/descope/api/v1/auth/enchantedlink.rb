# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module EnchantedLink
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def enchanted_link_sign_in(login_id: nil, uri: nil, login_options: nil, refresh_token: nil)
            # Sign-in existing user by sending an enchanted link via email.
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/SignInEnchantedLinkEmail/
            validate_login_id(login_id)
            validate_refresh_token_provided(login_options, refresh_token)
            body = enchanted_link_compose_signin_body(login_id, uri, login_options)
            uri = enchanted_link_compose_signin_url
            post(uri, body, nil, refresh_token)
          end

          def enchanted_link_sign_up(login_id: nil, uri: nil, user: {})
            # Sign-up new end user by sending an enchanted link via email
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/SignUpEnchantedLink/

            unless adjust_and_verify_delivery_method(Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id, user)
              raise Descope::ArgumentException.new(
                'Invalid delivery method',
                code: 400
              )
            end

            body = enchanted_link_compose_signup_body(login_id, uri, user)
            uri = enchanted_link_compose_signup_url
            post(uri, body)
          end

          def enchanted_link_sign_up_or_in(login_id: nil, uri: nil, login_options: nil)
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/SignUpOrInEnchantedLinkEmail/
            body = enchanted_link_compose_signin_body(login_id, uri, login_options)
            uri = enchanted_link_compose_sign_up_or_in_url
            post(uri, body)
          end

          def enchanted_link_update_user_email(login_id: nil, email: nil, uri: nil, add_to_login_ids: nil, on_merge_use_existing: nil, provider_id: nil, template_id: nil, template_options: nil, refresh_token: nil)
            validate_login_id(login_id)
            validate_token_not_empty(refresh_token)
            validate_email(email)

            body = enchanted_link_compose_update_user_email_body(
              login_id, email, add_to_login_ids, on_merge_use_existing
            )
            body[:redirectUrl] = uri
            body[:providerId] = provider_id if provider_id
            body[:templateId] = template_id if template_id
            body[:templateOptions] = template_options if template_options
            uri = UPDATE_USER_EMAIL_ENCHANTEDLINK_PATH
            post(uri, body, {}, refresh_token)
          end

          def enchanted_link_verify_token(token = nil)
            validate_token_not_empty(token)
            post(VERIFY_ENCHANTEDLINK_AUTH_PATH, { token: })
          end

          def enchanted_link_get_session(pending_ref = nil)
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/GetEnchantedLinkSession/
            res = post(GET_SESSION_ENCHANTEDLINK_AUTH_PATH, { pendingRef: pending_ref })
            cookies = res.fetch(COOKIE_DATA_NAME, {})
            refresh_cookie = cookies.fetch(REFRESH_SESSION_COOKIE_NAME, nil) || res.fetch('refreshJwt', nil)
            generate_jwt_response(response_body: res, refresh_cookie:)
          end

          private

          def enchanted_link_compose_signin_body(login_id, uri, login_options)
            login_options ||= {}
            unless login_options.is_a?(Hash)
              raise Descope::ArgumentException.new(
                'Unable to read login_option, not a Hash',
                code: 400
              )
            end

            body = {
              loginId: login_id,
              redirectUrl: uri,
              loginOptions: {}
            }

            body[:loginOptions][:stepup] = login_options.fetch(:stepup, false)
            body[:loginOptions][:mfa] = login_options.fetch(:mfa, false)
            body[:loginOptions][:customClaims] = login_options.fetch(:custom_claims, {})
            body[:loginOptions][:ssoAppId] = login_options.fetch(:sso_app_id, nil)

            body
          end

          def enchanted_link_compose_signin_url
            compose_url(SIGN_IN_AUTH_ENCHANTEDLINK_PATH, Descope::Mixins::Common::DeliveryMethod::EMAIL)
          end

          def enchanted_link_compose_signup_url
            compose_url(SIGN_UP_AUTH_ENCHANTEDLINK_PATH, Descope::Mixins::Common::DeliveryMethod::EMAIL)
          end

          def enchanted_link_compose_sign_up_or_in_url
            compose_url(SIGN_UP_OR_IN_AUTH_ENCHANTEDLINK_PATH, Descope::Mixins::Common::DeliveryMethod::EMAIL)
          end

          def enchanted_link_compose_signup_body(login_id, uri, user)
            body = {
              loginId: login_id,
              redirectUrl: uri
            }

            unless user.nil? || user.empty?
              body[:user] = enchantedlink_user_compose_update_body(**user) unless user.empty?

              method_str, val = get_login_id_by_method(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, user:)
              body[method_str.to_sym] = val
            end

            body
          end

          def enchanted_link_compose_update_user_email_body(login_id, email, add_to_login_ids, on_merge_use_existing)
            body = {
              loginId: login_id,
              email:
            }

            body[:addToLoginIds] = add_to_login_ids if add_to_login_ids
            body[:onMergeUseExisting] = on_merge_use_existing if on_merge_use_existing

            body
          end


          private
          def enchantedlink_user_compose_update_body(login_id: nil, name: nil, phone: nil, email: nil, given_name: nil, middle_name: nil, family_name: nil)
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
