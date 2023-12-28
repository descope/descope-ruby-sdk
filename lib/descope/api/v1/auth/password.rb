# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Auth
        # Holds all the password API calls
        module Password
          include Descope::Mixins::Validation
          def sign_up(login_id: nil, password: nil, user: nil)
            # Sign up (create) a new user using a login ID and password.
            # (optional) Include additional user metadata that you wish to save.
            validate_login_id(login_id)
            validate_password(password)
            post(SIGN_UP_PASSWORD_PATH, _compose_signup_body(login_id, password, user))
          end

          private

          def _compose_signup_body(login_id, password, user)
            body = {
              loginId: login_id,
              password: password
            }

            body[:user] = user unless user.nil?
            body
          end
        end
      end
    end
  end
end
