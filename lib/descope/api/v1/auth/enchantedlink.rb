# frozen_string_literal: true
module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module EnhancedLink
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def enchanted_link_sign_in(login_id: nil, uri: nil, login_options: nil, refresh_token: nil)
            # Sign-in existing user by sending an enchanted link via email.
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/SignInEnchantedLinkEmail/
            validate_login_id(login_id)
            validate_refresh_token_provided(login_options: login_options, refresh_token: refresh_token)

            body = compose_signin_body(login_id, uri, login_options)
            uri = compose_signin_url
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

            body = compose_signup_body(login_id, uri, user)
            uri = compose_signup_url
            post(uri, body)
          end

          def enchanted_link_sign_up_or_in(login_id: nil, uri: nil)
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/SignUpOrInEnchantedLinkEmail/
            body = compose_signin_body(login_id, uri)
            uri = compose_sign_up_or_in_url
            puts "uri: #{uri}"
            post(uri, body)
          end

          def enchanted_link_verify_token(token: nil)
            validate_token_not_empty(token)
            post(GET_SESSION_ENCHANTEDLINK_AUTH_PATH, { token: token })
          end

          def enchanted_link_get_session(pending_ref: nil)
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/GetEnchantedLinkSession/
            res = post( GET_SESSION_ENCHANTEDLINK_AUTH_PATH, { pendingRef: pending_ref })
            generate_jwt_response(response_body: res, refresh_cookie: res['refreshJwt'])
          end

          private

          def compose_signin_body(login_id, uri, login_options = nil)
            login_options ||= {}
            unless login_options.is_a?(Hash)
              raise Descope::ArgumentException.new(
                'Unable to read login_option, not a Hash',
                code: 400
              )
            end

            {
              loginId: login_id,
              redirectUrl: uri,
              loginOptions: login_options.to_h
            }
          end

          def compose_signin_url
            compose_url(SIGN_IN_AUTH_ENCHANTEDLINK_PATH, Descope::Mixins::Common::DeliveryMethod::EMAIL)
          end

          def compose_signup_url
            compose_url(SIGN_UP_AUTH_ENCHANTEDLINK_PATH, Descope::Mixins::Common::DeliveryMethod::EMAIL)
          end

          def compose_sign_up_or_in_url
            compose_url(SIGN_UP_OR_IN_AUTH_ENCHANTEDLINK_PATH, Descope::Mixins::Common::DeliveryMethod::EMAIL)
          end

          def compose_signup_body(login_id, uri, user)
            body = {
              loginId: login_id,
              redirectUrl: uri
            }

            unless user.nil? || user.empty?
              body[:user] = user
              method_str, val = get_login_id_by_method(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, user: user)
              body[method_str.to_sym] = val
            end

            body
          end
        end
      end
    end
  end
end
