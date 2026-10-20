# frozen_string_literal: true

require 'descope/api/v1/management/common'
require 'descope/api/v1/management/user'
require 'descope/api/v1/management/flow'
require 'descope/api/v1/management/access_key'
require 'descope/api/v1/management/tenant'
require 'descope/api/v1/management/permission'
require 'descope/api/v1/management/role'
require 'descope/api/v1/management/project'
require 'descope/api/v1/management/authz'
require 'descope/api/v1/management/audit'
require 'descope/api/v1/management/sso_application'
require 'descope/api/v1/management/sso_settings'
require 'descope/api/v1/management/scim'
require 'descope/api/v1/management/password'
require 'descope/api/v1/management/outbound_app'
require 'descope/api/v1/management/group'
require 'descope/api/v1/management/fga'
require 'descope/api/v1/management/third_party_application'
require 'descope/api/v1/management/management_key'
require 'descope/api/v1/management/analytics'
require 'descope/api/v1/management/descoper'
require 'descope/api/v1/management/engine'
require 'descope/api/v1/management/lists'
require 'descope/api/v1/management/jwt_template'
require 'descope/api/v1/management/scope_claim_mapping'

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
        include Descope::Api::V1::Management::Role
        include Descope::Api::V1::Management::Project
        include Descope::Api::V1::Management::Authz
        include Descope::Api::V1::Management::Audit
        include Descope::Api::V1::Management::SSOApplication
        include Descope::Api::V1::Management::SSOSettings
        include Descope::Api::V1::Management::SCIM
        include Descope::Api::V1::Management::Password
        include Descope::Api::V1::Management::OutboundApp
        include Descope::Api::V1::Management::Group
        include Descope::Api::V1::Management::FGA
        include Descope::Api::V1::Management::ThirdPartyApplication
        include Descope::Api::V1::Management::ManagementKey
        include Descope::Api::V1::Management::Analytics
        include Descope::Api::V1::Management::Descoper
        include Descope::Api::V1::Management::Engine
        include Descope::Api::V1::Management::Lists
        include Descope::Api::V1::Management::JWTTemplate
        include Descope::Api::V1::Management::ScopeClaimMapping
      end
    end
  end
end
