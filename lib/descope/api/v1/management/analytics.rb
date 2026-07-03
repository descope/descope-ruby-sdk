# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for analytics
        module Analytics
          include Descope::Api::V1::Management::Common

          def analytics_search(
            from_ts:,
            to_ts:,
            actions: nil,
            excluded_actions: nil,
            devices: nil,
            methods: nil,
            geos: nil,
            tenants: nil,
            group_by_action: false,
            group_by_device: false,
            group_by_method: false,
            group_by_geo: false,
            group_by_tenant: false,
            group_by_referrer: false,
            group_by_created: false
          )
            # Search project analytics based on given parameters
            # from_ts (int): Retrieve records newer than given time in epoch milliseconds
            # to_ts (int): Retrieve records older than given time in epoch milliseconds
            # actions (Array): Optional list of actions to filter by
            # excluded_actions (Array): Optional list of actions to exclude
            # devices (Array): Optional list of devices to filter by
            # methods (Array): Optional list of methods to filter by
            # geos (Array): Optional list of geos to filter by. Geo is currently country code like "US", "IL", etc.
            # tenants (Array): Optional list of tenants to filter by
            # group_by_* (bool): Optional grouping flags for the returned analytics
            request_params = {
              from: from_ts,
              to: to_ts,
              groupByAction: group_by_action,
              groupByDevice: group_by_device,
              groupByMethod: group_by_method,
              groupByGeo: group_by_geo,
              groupByTenant: group_by_tenant,
              groupByReferrer: group_by_referrer,
              groupByCreated: group_by_created
            }
            request_params[:actions] = actions unless actions.nil?
            request_params[:excludedActions] = excluded_actions unless excluded_actions.nil?
            request_params[:devices] = devices unless devices.nil?
            request_params[:methods] = methods unless methods.nil?
            request_params[:geos] = geos unless geos.nil?
            request_params[:tenants] = tenants unless tenants.nil?

            post(ANALYTICS_SEARCH_PATH, request_params)
          end
        end
      end
    end
  end
end
