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
            uri = compose_signin_uri
            post(uri, body, nil, refresh_token)
          end

          def enchanted_link_sign_up(login_id: nil, uri: nil, user: {})
            # Sign-up new end user by sending an enchanted link via email
            # @see https://docs.descope.com/api/openapi/enchantedlink/operation/SignUpEnchantedLink/

            unless adjust_and_verify_delivery_method(DeliveryMethod::EMAIL, login_id, user)
              raise Descope::ArgumentException.new(
                'Invalid delivery method',
                code: 400
              )
            end

            body = compose_signup_body(login_id, uri, user)
            uri = compose_signup_uri
            post(uri, body)
          end

          private

          def compose_signin_body(login_id, uri, login_options = {})
            unless login_options.is_a?(Hash)
              raise Descope::ArgumentException.new(
                'Unable to read login_option, not a Hash',
                code: 400
              )
            end

            {
              loginId: login_id,
              URI: uri,
              loginOptions: login_options.to_h
            }
          end

          def compose_signin_uri
            compose_url(SIGN_IN_AUTH_ENCHANTEDLINK_PATH, DeliveryMethod::EMAIL)
          end

          def compose_signup_body(login_id, uri, user)
            body = {
              loginId: login_id,
              URI: uri
            }

            unless user.nil? || user.empty?
              body[:user] = user
              method_str, val = get_login_id_by_method(method: DeliveryMethod::EMAIL, user: user)
              puts "method_str: #{method_str}, val: #{val}"
              body[method_str.to_sym] = val
            end

            body
          end

          def compose_signup_uri
            compose_url(SIGN_UP_AUTH_ENCHANTEDLINK_PATH, DeliveryMethod::EMAIL)
          end

          def compose_get_session_body(pending_ref)
            {"pendingRef": pending_ref}
          end
        end
      end
    end
  end
end
