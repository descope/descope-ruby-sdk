
module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Users
          # Load an existing user
          def load(login_id)
            raise Descope::Exception::MissingLoginId if login_id.to_s.empty?

            path = "v1/mgmt/user"
            request_params = {
              login_id: login_id
            }
            get(path, params: request_params)
          end
        end
      end

    end
  end
end