require 'descope/api/v1/mgmt/user'

module Descope
  module Api
    module V1
      # Holds all the management API calls
      module Mgmt
        include Descope::Api::V1::Mgmt::User
      end
    end
  end
end
