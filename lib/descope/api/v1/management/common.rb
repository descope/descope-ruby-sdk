# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Common Management constants
        module Common
          # tenant
          TENANT_CREATE_PATH = '/v1/mgmt/tenant/create'
          TENANT_UPDATE_PATH = '/v1/mgmt/tenant/update'
          TENANT_DELETE_PATH = '/v1/mgmt/tenant/delete'
          TENANT_LOAD_PATH = '/v1/mgmt/tenant'
          TENANT_LOAD_ALL_PATH = '/v1/mgmt/tenant/all'
          TENANT_SEARCH_ALL_PATH = '/v1/mgmt/tenant/search'

          # userUSER_CREATE_PATH
          USER_CREATE_PATH = '/v1/mgmt/user/create'
          USER_CREATE_BATCH_PATH = '/v1/mgmt/user/create/batch'
          USER_UPDATE_PATH = '/v1/mgmt/user/update'
          USER_DELETE_PATH = '/v1/mgmt/user/delete'
          USER_LOGOUT_PATH = '/v1/mgmt/user/logout'
          USER_DELETE_ALL_TEST_USERS_PATH = '/v1/mgmt/user/test/delete/all'
          USER_LOAD_PATH = '/v1/mgmt/user'
          USERS_SEARCH_PATH = '/v1/mgmt/user/search'
          USER_GET_PROVIDER_TOKEN = '/v1/mgmt/user/provider/token'
          USER_UPDATE_STATUS_PATH = '/v1/mgmt/user/update/status'
          USER_UPDATE_LOGIN_ID_PATH = '/v1/mgmt/user/update/loginid'
          USER_UPDATE_EMAIL_PATH = '/v1/mgmt/user/update/email'
          USER_UPDATE_PHONE_PATH = '/v1/mgmt/user/update/phone'
          USER_UPDATE_NAME_PATH = '/v1/mgmt/user/update/name'
          USER_UPDATE_PICTURE_PATH = '/v1/mgmt/user/update/picture'
          USER_UPDATE_CUSTOM_ATTRIBUTE_PATH = '/v1/mgmt/user/update/customAttribute'
          USER_ADD_ROLE_PATH = '/v1/mgmt/user/update/role/add'
          USER_REMOVE_ROLE_PATH = '/v1/mgmt/user/update/role/remove'
          USER_SET_PASSWORD_PATH = '/v1/mgmt/user/password/set'
          USER_EXPIRE_PASSWORD_PATH = '/v1/mgmt/user/password/expire'
          USER_ADD_TENANT_PATH = '/v1/mgmt/user/update/tenant/add'
          USER_REMOVE_TENANT_PATH = '/v1/mgmt/user/update/tenant/remove'
          USER_GENERATE_OTP_FOR_TEST_PATH = '/v1/mgmt/tests/generate/otp'
          USER_GENERATE_MAGIC_LINK_FOR_TEST_PATH = '/v1/mgmt/tests/generate/magiclink'
          USER_GENERATE_ENCHANTED_LINK_FOR_TEST_PATH = '/v1/mgmt/tests/generate/enchantedlink'
          USER_GENERATE_EMBEDDED_LINK_PATH = '/v1/mgmt/user/signin/embeddedlink'

          # access key
          ACCESS_KEY_CREATE_PATH = '/v1/mgmt/accesskey/create'
          ACCESS_KEY_LOAD_PATH = '/v1/mgmt/accesskey'
          ACCESS_KEYS_SEARCH_PATH = '/v1/mgmt/accesskey/search'
          ACCESS_KEY_UPDATE_PATH = '/v1/mgmt/accesskey/update'
          ACCESS_KEY_DEACTIVATE_PATH = '/v1/mgmt/accesskey/deactivate'
          ACCESS_KEY_ACTIVATE_PATH = '/v1/mgmt/accesskey/activate'
          ACCESS_KEY_DELETE_PATH = '/v1/mgmt/accesskey/delete'

          # sso
          SSO_SETTINGS_PATH = '/v1/mgmt/sso/settings'
          SSO_METADATA_PATH = '/v1/mgmt/sso/metadata'
          SSO_MAPPING_PATH = '/v1/mgmt/sso/mapping'

          # jwt
          UPDATE_JWT_PATH = '/v1/mgmt/jwt/update'

          # permission
          PERMISSION_CREATE_PATH = '/v1/mgmt/permission/create'
          PERMISSION_UPDATE_PATH = '/v1/mgmt/permission/update'
          PERMISSION_DELETE_PATH = '/v1/mgmt/permission/delete'
          PERMISSION_LOAD_ALL_PATH = '/v1/mgmt/permission/all'

          # role
          ROLE_CREATE_PATH = '/v1/mgmt/role/create'
          ROLE_UPDATE_PATH = '/v1/mgmt/role/update'
          ROLE_DELETE_PATH = '/v1/mgmt/role/delete'
          ROLE_LOAD_ALL_PATH = '/v1/mgmt/role/all'

          # flow
          FLOW_LIST_PATH = '/v1/mgmt/flow/list'
          FLOW_IMPORT_PATH = '/v1/mgmt/flow/import'
          FLOW_EXPORT_PATH = '/v1/mgmt/flow/export'

          # theme
          THEME_IMPORT_PATH = '/v1/mgmt/theme/import'
          THEME_EXPORT_PATH = '/v1/mgmt/theme/export'

          # group
          GROUP_LOAD_ALL_PATH = '/v1/mgmt/group/all'
          GROUP_LOAD_ALL_FOR_MEMBER_PATH = '/v1/mgmt/group/member/all'
          GROUP_LOAD_ALL_GROUP_MEMBERS_PATH = '/v1/mgmt/group/members'

          # Audit
          AUDIT_SEARCH = '/v1/mgmt/audit/search'

          # Authz ReBAC
          AUTHZ_SCHEMA_SAVE = '/v1/mgmt/authz/schema/save'
          AUTHZ_SCHEMA_DELETE = '/v1/mgmt/authz/schema/delete'
          AUTHZ_SCHEMA_LOAD = '/v1/mgmt/authz/schema/load'
          AUTHZ_NS_SAVE = '/v1/mgmt/authz/ns/save'
          AUTHZ_NS_DELETE = '/v1/mgmt/authz/ns/delete'
          AUTHZ_RD_SAVE = '/v1/mgmt/authz/rd/save'
          AUTHZ_RD_DELETE = '/v1/mgmt/authz/rd/delete'
          AUTHZ_RE_CREATE = '/v1/mgmt/authz/re/create'
          AUTHZ_RE_DELETE = '/v1/mgmt/authz/re/delete'
          AUTHZ_RE_DELETE_RESOURCES = '/v1/mgmt/authz/re/deleteresources'
          AUTHZ_RE_HAS_RELATIONS = '/v1/mgmt/authz/re/has'
          AUTHZ_RE_WHO = '/v1/mgmt/authz/re/who'
          AUTHZ_RE_RESOURCE = '/v1/mgmt/authz/re/resource'
          AUTHZ_RE_TARGETS = '/v1/mgmt/authz/re/targets'
          AUTHZ_RE_TARGET_ALL = '/v1/mgmt/authz/re/targetall'

          # Project
          PROJECT_UPDATE_NAME = '/v1/mgmt/project/eupdate/name'
          PROJECT_CLONE = '/v1/mgmt/project/clone'
          PROJECT_EXPORT_PATH = '/v1/mgmt/project/export'
          PROJECT_IMPORT_PATH = '/v1/mgmt/project/import'
          PROJECT_DELETE_PATH = '/v1/mgmt/project/delete'

          # Represents a tenant association for a User or Access Key. The tenant_id is required to denote
          # which tenant the user or access key belongs to. The role_names array is an optional list of
          # roles for the user or access key in this specific tenant.
          def associated_tenants_to_hash(associated_tenants)
            associated_tenant_list = []
            associated_tenants.each do |tenant|
              associated_tenant_list.append(
                {
                  "tenantId": tenant[:tenant_id],
                  "roleNames": tenant[:role_names]
                }
              )
            end
            associated_tenant_list
          end

          def get_method_string(method: nil)
            name = {
              DeliveryMethod::WHATSAPP => 'whatsapp',
              DeliveryMethod::SMS => 'sms',
              DeliveryMethod::EMAIL => 'email'
            }.key(method)

            raise ArgumentException, "Unknown delivery method: #{method}" unless name

            name
          end

          module DeliveryMethod
            WHATSAPP = 1
            SMS = 2
            EMAIL = 3
          end
        end
      end
    end
  end
end
