# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Audit
          def audit_search(
            user_ids: nil,
            actions: nil,
            exclude_actions: nil,
            devices: nil,
            methods: nil,
            geos: nil,
            remote_addresses: nil,
            login_ids: nil,
            tenants: nil,
            no_tenants: false,
            text: nil,
            from_ts: nil,
            to_ts: nil
          )
            # Search the audit trail up to last 30 days based on given parameters
            # user_ids (Array): Optional list of user IDs to filter by
            # actions (Array): Optional list of actions to filter by
            # excluded_actions (Array): Optional list of actions to exclude
            # devices (Array): Optional list of devices to filter by. Current devices supported are "Bot"/"Mobile"/"Desktop"/"Tablet"/"Unknown"
            # methods (Array): Optional list of methods to filter by. Current auth methods are "otp"/"totp"/"magiclink"/"oauth"/"saml"/"password"
            # geos (Array): Optional list of geos to filter by. Geo is currently country code like "US", "IL", etc.
            # remote_addresses (Array): Optional list of remote addresses to filter by
            # login_ids (Array): Optional list of login IDs to filter by
            # tenants (Array): Optional list of tenants to filter by
            # no_tenants (bool): Should audits without any tenants always be included
            # text (str): Free text search across all fields
            # from_ts (datetime): Retrieve records newer than given time but not older than 30 days
            # to_ts (datetime): Retrieve records older than given time
            request_params = {
              noTenants: no_tenants
            }
            request_params[:userIds] = user_ids unless user_ids.nil?
            request_params[:actions] = actions unless actions.nil?
            request_params[:excludeActions] = exclude_actions unless exclude_actions.nil?
            request_params[:devices] = devices unless devices.nil?
            request_params[:methods] = methods unless methods.nil?
            request_params[:geos] = geos unless geos.nil?
            request_params[:remoteAddresses] = remote_addresses unless remote_addresses.nil?
            request_params[:externalIds] = login_ids unless login_ids.nil?
            request_params[:tenants] = tenants unless tenants.nil?
            request_params[:text] = text unless text.nil?
            request_params[:from] = from_ts.to_i * 1000 unless from_ts.nil?
            request_params[:to] = to_ts.to_i * 1000 unless to_ts.nil?
            res = post(AUDIT_SEARCH, request_params)
            raise Descope::AuthException, "could not get audits: #{res}" if res['audits'].nil?

            { 'audits' => res['audits'].map { |audit| convert_audit_record(audit) } }
          end

          private

          def convert_audit_record(audit)
            {
              'projectId' => audit['projectId'] || '',
              'userId' => audit['userId'] || '',
              'action' => audit['action'] || '',
              'occurred' => audit['occurred'] || '',
              'device' => audit['device'] || '',
              'method' => audit['method'] || '',
              'geo' => audit['geo'] || '',
              'remoteAddress' => audit['remoteAddress'] || '',
              'loginIds' => audit['externalIds'] || '',
              'tenants' => audit['tenants'] || '',
              'data' => audit['data'] || ''
            }
          end
        end
      end
    end
  end
end
