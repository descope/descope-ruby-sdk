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
            # Initiate a sign-in process by sending an enchanted link to a new end user.
            validate_login_id(login_id)
            # validate_refresh_token_provided(refresh_token)

            body = compose_signin_body(login_id, uri, login_options)
            uri = compose_signin_uri
            post(uri, body, nil, refresh_token)
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
        end
      end
    end
  end
end
