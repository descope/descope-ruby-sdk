# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Outbound App Management API calls
        # Manage outbound application tokens for users
        # @see https://docs.descope.com/api/management/outbound-apps/
        module OutboundApp
          include Descope::Mixins::Validation
          include Descope::Api::V1::Management::Common

          # Outbound App paths
          OUTBOUND_APP_FETCH_USER_TOKEN_PATH = '/v1/mgmt/outbound/app/user/token'
          OUTBOUND_APP_DELETE_USER_TOKENS_PATH = '/v1/mgmt/outbound/user/tokens'
          OUTBOUND_APP_DELETE_TOKEN_BY_ID_PATH = '/v1/mgmt/outbound/token'

          # Fetch outbound application user token with the specified scopes.
          # @see https://docs.descope.com/api/management/outbound-apps/fetch-outbound-app-user-token
          #
          # @param app_id [String] The outbound application ID
          # @param user_id [String] The user ID to fetch the token for
          # @param scopes [Array<String>] Optional list of scopes for the token
          # @param with_refresh_token [Boolean] Optional flag to include refresh token (default: false)
          # @param force_refresh [Boolean] Optional flag to force token refresh (default: false)
          # @param tenant_id [String] Optional tenant ID
          #
          # @return [Hash] Token information including accessToken, accessTokenExpiry, etc.
          def fetch_outbound_app_user_token(app_id:, user_id:, scopes: nil, with_refresh_token: false, force_refresh: false, tenant_id: nil)
            validate_app_id(app_id)
            validate_user_id(user_id)

            body = {
              appId: app_id,
              userId: user_id
            }

            body[:scopes] = scopes if scopes.is_a?(Array) && !scopes.empty?
            body[:tenantId] = tenant_id unless tenant_id.nil? || tenant_id.empty?

            # Only include options if at least one is true
            if with_refresh_token || force_refresh
              body[:options] = {
                withRefreshToken: with_refresh_token,
                forceRefresh: force_refresh
              }
            end

            post(OUTBOUND_APP_FETCH_USER_TOKEN_PATH, body)
          end

          # Delete outbound application tokens by appId or userId.
          # At least one of app_id or user_id must be provided.
          # @see https://docs.descope.com/api/management/outbound-apps/delete-outbound-app-user-tokens
          #
          # @param app_id [String] Optional outbound application ID
          # @param user_id [String] Optional user ID
          #
          # @return [void]
          def delete_outbound_app_user_tokens(app_id: nil, user_id: nil)
            if (app_id.nil? || app_id.empty?) && (user_id.nil? || user_id.empty?)
              raise Descope::ArgumentException.new(
                'At least one of app_id or user_id must be provided',
                code: 400
              )
            end

            query_params = {}
            query_params[:appId] = app_id unless app_id.nil? || app_id.empty?
            query_params[:userId] = user_id unless user_id.nil? || user_id.empty?

            delete(OUTBOUND_APP_DELETE_USER_TOKENS_PATH, query_params)
          end

          # Delete outbound application token by its ID.
          # @see https://docs.descope.com/api/management/outbound-apps/delete-outbound-app-token-by-id
          #
          # @param token_id [String] The token ID to delete
          #
          # @return [void]
          def delete_outbound_app_token_by_id(token_id:)
            validate_token_id(token_id)

            query_params = { id: token_id }
            delete(OUTBOUND_APP_DELETE_TOKEN_BY_ID_PATH, query_params)
          end

          private

          def validate_app_id(app_id)
            return unless app_id.nil? || app_id.empty?

            raise Descope::ArgumentException.new(
              'app_id cannot be empty',
              code: 400
            )
          end

          def validate_token_id(token_id)
            return unless token_id.nil? || token_id.empty?

            raise Descope::ArgumentException.new(
              'token_id cannot be empty',
              code: 400
            )
          end
        end
      end
    end
  end
end
