# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module MagicLink
          include Descope::Mixins::Validation
          include Descope::Mixins::Common::EndpointsV1
          include Descope::Mixins::Common::EndpointsV2

          def magic_link_email_sign_up(method: nil, login_id: nil, uri: nil, user: {}, provider_id: nil, template_id: nil)
            # Sign-up new end user by sending a magic link via email
            # @see https://docs.descope.com/api/openapi/magiclink/operation/SignUpMagicLinkEmail/
            validate_login_id(login_id)

            body = compose_signup_body(method, login_id, uri, user)
            body[:providerId] = provider_id if provider_id
            body[:templateId] = template_id if template_id
            uri = compose_signup_url(method)
            res = post(uri, body)
            extract_masked_address(res, method)
          end

          def magic_link_email_sign_in(method: nil, login_id: nil, uri: nil, login_options: nil, refresh_token: nil)
            validate_login_id(login_id)
            validate_refresh_token_provided(login_options, refresh_token)
            body = compose_signin_body(login_id, uri, login_options)
            uri = compose_signin_url(method)
            res = post(uri, body, {}, refresh_token)
            extract_masked_address(res, method)
          end

          def magic_link_email_sign_up_or_in(method, login_id, uri)
            body = compose_signin_body(login_id, uri)
            uri = compose_sign_up_or_in_url(method)
            res = post(uri, body)
            extract_masked_address(res, method)
          end

          private

          def compose_signin_url(method = Descope::Mixins::Common::DeliveryMethod::EMAIL)
            compose_url(SIGN_IN_AUTH_MAGICLINK_PATH, method)
          end

          def compose_signup_url(method = Descope::Mixins::Common::DeliveryMethod::EMAIL)
            compose_url(SIGN_UP_AUTH_MAGICLINK_PATH, method)
          end

          def compose_sign_up_or_in_url(method = Descope::Mixins::Common::DeliveryMethod::EMAIL)
            compose_url(SIGN_UP_OR_IN_AUTH_MAGICLINK_PATH, method)
          end

          def compose_signup_body(method, login_id, uri, user = nil)
            body = {
              loginId: login_id,
              redirectUrl: uri
            }

            unless user.nil?
              body[:user] = user
              method_str, val = get_login_id_by_method(method:, user:)
              body[method_str.to_sym] = val
            end

            body
          end

          def compose_update_user_email_body(login_id, email, add_to_login_ids, on_merge_use_existing)
            {
              loginId: login_id,
              email:,
              addToLoginIDs: add_to_login_ids,
              onMergeUseExisting: on_merge_use_existing,
            }
          end

          def compose_update_user_phone_body(login_id, phone, add_to_login_ids, on_merge_use_existing)
            {
              loginId: login_id,
              phone:,
              addToLoginIDs: add_to_login_ids,
              onMergeUseExisting: on_merge_use_existing
            }
          end
        end
      end
    end
  end
end
