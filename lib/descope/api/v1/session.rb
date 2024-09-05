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
          #  Make sure you set Enable refresh token rotation in the Project Settings before using this.
          validate_refresh_token_not_nil(refresh_token)
          validate_token(refresh_token, audience)
          res = post(REFRESH_TOKEN_PATH, {}, {}, refresh_token)
          cookies = res.fetch(COOKIE_DATA_NAME, {})
          refresh_cookie = cookies.fetch(REFRESH_SESSION_COOKIE_NAME, nil) || res.fetch('refreshJwt', nil)
          generate_jwt_response(response_body: res, refresh_cookie:, audience:)
        end

        def me(refresh_token = nil)
          get(ME_PATH, {}, {}, refresh_token)
        end

        def sign_out(refresh_token = nil)
          post(LOGOUT_PATH, {}, {}, refresh_token)
        end

        def sign_out_all(refresh_token = nil)
          post(LOGOUT_ALL_PATH, {}, {}, refresh_token)
        end

        def validate_session(session_token: nil, audience: nil)
          # Validate a session token. Call this function for every incoming request to your
          # private endpoints. Alternatively, use validate_and_refresh_session in order to
          # automatically refresh expired sessions. If you need to use these specific claims
          # [amr, drn, exp, iss, rexp, sub, jwt] in the top level of the response dict, please use
          # them from the sessionToken key instead, as these claims will soon be deprecated from the top level
          # of the response dict.
          # Return a hash includes the session token and all JWT claims

          if session_token.nil? || session_token.empty?
            raise Descope::AuthException.new('Session token is required for validation', code: 400)
          end

          @logger.debug("Validating session token: #{session_token}")
          res = validate_token(session_token, audience)
          @logger.debug("Session token validation response: #{res}")
          # Duplicate for saving backward compatibility but keep the same structure as the refresh operation response
          res[SESSION_TOKEN_NAME] = deep_copy(res)
          session_props = adjust_properties(res, true)
          @logger.debug("session validation jwt response properties: #{session_props}")
          session_props
        end

        def validate_and_refresh_session(session_token: nil, refresh_token: nil, audience: nil)
          # Validate the session token and refresh it if it has expired, the session token will automatically be refreshed.
          # Either the session_token or the refresh_token must be provided.
          # Call this function for every incoming request to your
          # private endpoints. Alternatively, use validate_session to only validate the session.

          raise Descope::AuthException.new('Session token is missing', code: 400) if session_token.nil?

          begin
            @logger.debug("Validating session token: #{session_token}")
            validate_session(session_token:, audience:)
          rescue Descope::AuthException
            @logger.debug("Session is invalid, refreshing session with refresh token: #{refresh_token}")
            refresh_session(refresh_token:, audience:)
          end
        end

        def history(refresh_token = nil)
          # Retrieve user authentication history for the refresh token
          # Return List in the format
          #              [
          #                 {
          #                     "userId": "User's ID",
          #                     "loginTime": "User'sLogin time",
          #                     "city": "User's city",
          #                     "country": "User's country",
          #                     "ip": User's IP
          #                 }
          #             ]
          validate_refresh_token_not_nil(refresh_token)
          get(HISTORY_PATH, {}, {}, refresh_token)
        end
      end
    end
  end
end
