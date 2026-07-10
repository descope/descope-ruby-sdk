# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for SSO groups querying
        module Group
          include Descope::Api::V1::Management::Common

          def load_all_groups(tenant_id:)
            # Load all groups for a given tenant id.
            post(GROUP_LOAD_ALL_PATH, { tenantId: tenant_id })
          end

          def load_all_groups_for_members(tenant_id:, user_ids: nil, login_ids: nil)
            # Load all groups for the given user's or login IDs (can be given either).
            post(
              GROUP_LOAD_ALL_FOR_MEMBER_PATH,
              {
                tenantId: tenant_id,
                loginIds: login_ids,
                userIds: user_ids
              }
            )
          end

          def load_all_group_members(tenant_id:, group_id:)
            # Load all members of the given group id.
            post(
              GROUP_LOAD_ALL_GROUP_MEMBERS_PATH,
              {
                tenantId: tenant_id,
                groupId: group_id
              }
            )
          end
        end
      end
    end
  end
end
