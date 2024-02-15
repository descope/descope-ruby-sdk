require 'descope/api/v1/management'
require 'descope/api/v1/session'
require 'descope/api/v1/auth'

module Descope
  module Api
    module V1
      include Descope::Api::V1::Management
      include Descope::Api::V1::Session
      include Descope::Api::V1::Auth
    end
  end
end
