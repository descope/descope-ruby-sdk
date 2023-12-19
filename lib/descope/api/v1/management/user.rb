module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module User
          # Retrieve user information based on the provided Login ID
          def load(login_id: nil)
            # Load an existing user.
            if login_id.nil? || login_id.empty?
              raise Descope::AuthException, 'Failed loading user by login_id #{login_id}'
            end

            path = Common::USER_LOAD_PATH
            request_params = {}
            request_params[:loginId] = login_id unless login_id.nil?
            get(path, params: request_params)
          end

          def load_by_user_id(user_id: nil)
            # Retrieve user information based on the provided user ID
            # The user ID can be found on the user's JWT.
            raise Descope::AuthException, "Failed loading user by user_id #{user_id}" if user_id.nil? || user_id.empty?

            path = Common::USER_LOAD_PATH
            request_params = {}
            request_params[:userId] = user_id unless user_id.nil?
            get(path, params: request_params)
          end

        end
      end
    end
  end
end
