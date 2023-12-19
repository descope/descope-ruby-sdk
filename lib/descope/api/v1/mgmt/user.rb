module Descope
  module Api
    module V1
      module Mgmt
        # Management API calls
        module User
          # Load an existing user
          def load_user(login_id: nil, user_id: nil)
            if (login_id.nil? || login_id.empty?) && (user_id.nil? || user_id.empty?)
              raise Descope::MissingLoginOrUserId, 'Login ID is required to load a user'
            end

            path = '/v1/mgmt/user'
            request_params = {}
            request_params[:userId] = user_id unless user_id.nil?
            request_params[:loginId] = login_id unless login_id.nil?
            get(path, params: request_params)
          end
        end
      end
    end
  end
end
