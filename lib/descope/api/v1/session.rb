# frozen_string_literal: true
module Descope
  module Api
    module V1
      # Holds all session methods
      module Session
        include Descope::Mixins::Common
        include Descope::Mixins::Common::EndpointsV1
        include Descope::Mixins::Common::EndpointsV2

        def token_validation_key(project_id)
          get("#{PUBLIC_KEY_PATH}/#{project_id}")
        end

        def refresh_session(refresh_token: nil, audience: nil)
          #  Validate a session token. Call this function for every incoming request to your
          #  private endpoints. Alternatively, use validate_and_refresh_session in order to
          #  automatically refresh expired sessions. If you need to use these specific claims
          #  [amr, drn, exp, iss, rexp, sub, jwt] in the top level of the response dict, please use
          #  them from the sessionToken key instead, as these claims will soon be deprecated from the top level
          #  of the response dict.
          raise AuthException.new('Refresh token is required to refresh a session', code: 400) if refresh_token.nil? || refresh_token.empty?
          # validate_token(refresh_token, audience: audience)
          post(REFRESH_TOKEN_PATH, {}, {}, refresh_token)
        end

        def me
          get(ME_PATH)
        end

        def sign_out(refresh_token = nil)
          post(LOGOUT_PATH, {}, {}, refresh_token)
        end

        def sign_out_all(refresh_token = nil)
          post(LOGOUT_ALL_PATH, {}, {}, refresh_token)
        end

        def validate_session
          post(VALIDATE_SESSION_PATH)
        end
      end
    end
  end
end
