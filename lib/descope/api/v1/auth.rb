# frozen_string_literal: true

require 'descope/mixins/common'
require 'descope/api/v1/auth/password'


module Descope
  module Api
    module V1
      # Holds all the management API calls
      module Auth
        include Descope::Mixins::Common
        include Descope::Mixins::Common::EndpointsV1
        include Descope::Mixins::Common::EndpointsV2
        include Descope::Api::V1::Auth::Password

        ALGORITHM_KEY = 'alg'

        def generate_jwt_response(response_body, refresh_cookie = nil, audience = nil)
          jwt_response = _generate_auth_info(response_body, refresh_cookie, true, audience)

          jwt_response['user'] = response_body.key?('user') ? response_body['user'] : {}
          jwt_response['firstSeen'] = response_body.key?('firstSeen') ? response_body['firstSeen'] : true

          jwt_response
        end
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def _generate_auth_info(response_body, refresh_token, user_jwt, audience = nil)
        jwt_response = {}
        st_jwt = response_body['sessionJwt'] || ''
        _validate_token(st_jwt) if st_jwt != ''
        rt_jwt = response_body['refreshJwt'] || ''
        jwt_response[REFRESH_SESSION_TOKEN_NAME] = _validate_token(refresh_token, audience) if refresh_token
        jwt_response[REFRESH_SESSION_TOKEN_NAME] = _validate_token(rt_jwt, user_jwt) if rt_jwt != ''
        jwt_response = adjust_properties(jwt_response, user_jwt)

        if user_jwt
          jwt_response[COOKIE_DATA_NAME] = {
            exp: response_body['cookieExpiration'] || 0,
            maxAge: response_body['cookieMaxAge'] || 0,
            domain: response_body['cookieDomain'] || '',
            path: response_body['cookiePath'] || ''
          }
        end

        jwt_response
      end

      def adjust_properties(jwt_response, user_jwt)
        # Save permissions, roles and tenants info from Session token or from refresh token on the json top level
        if jwt_response[SESSION_TOKEN_NAME]
          jwt_response['permissions'] = jwt_response[SESSION_TOKEN_NAME]['permissions'] || []
          jwt_response['roles'] = jwt_response[SESSION_TOKEN_NAME]['roles'] || []
          jwt_response['tenants'] = jwt_response[SESSION_TOKEN_NAME]['tenants'] || {}
        elsif jwt_response[REFRESH_SESSION_TOKEN_NAME]
          jwt_response['permissions'] = jwt_response[REFRESH_SESSION_TOKEN_NAME]['permissions'] || []
          jwt_response['roles'] = jwt_response[REFRESH_SESSION_TOKEN_NAME]['roles'] || []
          jwt_response['tenants'] = jwt_response[REFRESH_SESSION_TOKEN_NAME]['tenants'] || {}
        else
          jwt_response['permissions'] = []
          jwt_response['roles'] = []
          jwt_response['tenants'] = {}
        end

        # Save the projectID also in the dict top level
        issuer =
          (jwt_response[SESSION_TOKEN_NAME] ? jwt_response[SESSION_TOKEN_NAME]['iss'] : nil) ||
          (jwt_response[REFRESH_SESSION_TOKEN_NAME] ? jwt_response[REFRESH_SESSION_TOKEN_NAME]['iss'] : nil) ||
          jwt_response['iss'] || ''


        jwt_response['projectID'] = issuer.split('/').last # support both url issuer and project ID issuer

        sub =
          (jwt_response[SESSION_TOKEN_NAME] ? jwt_response[SESSION_TOKEN_NAME]['sub'] : nil) ||
          (jwt_response[REFRESH_SESSION_TOKEN_NAME] ? jwt_response[REFRESH_SESSION_TOKEN_NAME]['sub'] : nil) ||
          jwt_response['sub'] || ''


        if user_jwt
          jwt_response['userId'] = sub # Save the userID also in the dict top level
        else
          jwt_response['keyId'] = sub # Save the AccessKeyID also in the dict top level
        end

        jwt_response
      end

      def _validate_token(token, _audience = nil)
        raise AuthException.new('Token validation received empty token', code: 500) if token.nil? || token.to_s.empty?

        unverified_header = jwt_get_unverified_header(token)
        alg_header = unverified_header[ALGORITHM_KEY]

        if alg_header.nil? || alg_header == 'none'
          raise AuthException.new('Token header is missing property: alg', code: 500)
        end

        kid = unverified_header['kid']
        raise AuthException.new('Token header is missing property: kid', code: 500) if kid.nil?

        fetch_public_keys if @public_keys == {} || @public_keys[kid].nil?
      end

      def jwt_get_unverified_header(token)
        begin
          decode_response = JWT.decode(token, nil, false)
        rescue JWT::DecodeError => e
          raise AuthException.new("Unable to parse token. #{e.message}", code: 500)
        end

        # The JWT.decode method returns an array where
        # the first element is the payload and the second element is the header.
        decode_response[1]
      end

      def fetch_public_keys
        response = token_validation_v2(@project_id)
        unless response.is_a?(Hash) && response.key?('keys')
          raise AuthException.new("Unable to fetch public keys. #{response.body}", code: response.code)
        end

        jwkeys_wrapper = response
        jwkeys = jwkeys_wrapper['keys']

        @public_keys = {}
        jwkeys.each do |key|
          loaded_kid, pub_key, alg = _validate_and_load_public_key(key)
          @public_keys[loaded_kid] = [pub_key, alg]
        rescue AuthException
          nil
        end
      end
    end
  end
end
