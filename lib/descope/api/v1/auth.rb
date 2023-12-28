# frozen_string_literal: true

require 'descope/api/v1/auth/password'

module Descope
  module Api
    module V1
      # Holds all the management API calls
      module Auth
        include Descope::Api::V1::Auth::Password
      end
    end
  end
end
