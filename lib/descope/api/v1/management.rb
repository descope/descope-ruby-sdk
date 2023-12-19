require 'descope/api/v1/management/common'
require 'descope/api/v1/management/user'

module Descope
  module Api
    module V1
      # Holds all the management API calls
      module Management
        include Descope::Api::V1::Management::User
        include Descope::Api::V1::Management::Common
      end
    end
  end
end
