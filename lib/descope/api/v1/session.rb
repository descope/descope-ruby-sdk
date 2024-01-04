# frozen_string_literal: true
module Descope
  module Api
    module V1
      # Holds all session methods
      module Session
        def token_validation_key(project_id)
          get("#{Descope::Mixins::Common::EndpointsV2::PUBLIC_KEY_PATH}/#{project_id}")
        end

        def refresh_session
          post(REFRESH_TOKEN_PATH)
        end

        def me
          get(ME_PATH)
        end

        def sign_out
          post(LOGOUT_PATH)
        end

        def sign_out_all
          post(LOGOUT_ALL_PATH)
        end

        def validate_session
          post(VALIDATE_SESSION_PATH)
        end
      end
    end
  end
end
