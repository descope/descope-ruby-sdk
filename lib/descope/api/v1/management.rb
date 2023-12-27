# frozen_string_literal: true

require 'descope/api/v1/management/common'
require 'descope/api/v1/management/user'
require 'descope/api/v1/management/flow'
require 'descope/api/v1/management/access_key'
require 'descope/api/v1/management/tenant'
require 'descope/api/v1/management/permission'

module Descope
  module Api
    module V1
      # Holds all the management API calls
      module Management
        include Descope::Api::V1::Management::Common
        include Descope::Api::V1::Management::User
        include Descope::Api::V1::Management::Flow
        include Descope::Api::V1::Management::AccessKey
        include Descope::Api::V1::Management::Tenant
        include Descope::Api::V1::Management::Permission
      end
    end
  end
end
