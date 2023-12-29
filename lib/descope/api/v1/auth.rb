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
          jwt_response = generate_auth_info(response_body, refresh_cookie, true, audience)
          puts "debug: jwt response: #{jwt_response}"
          jwt_response['user'] = response_body.key?('user') ? response_body['user'] : {}
          jwt_response['firstSeen'] = response_body.key?('firstSeen') ? response_body['firstSeen'] : true

          jwt_response
        end

        private

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def generate_auth_info(response_body, refresh_token, user_jwt, audience = nil)
          jwt_response = {}
          st_jwt = response_body['sessionJwt'] || ''
          validate_token(st_jwt) if st_jwt != ''
          rt_jwt = response_body['refreshJwt'] || ''
          jwt_response[REFRESH_SESSION_TOKEN_NAME] = validate_token(refresh_token, audience) if refresh_token
          jwt_response[REFRESH_SESSION_TOKEN_NAME] = validate_token(rt_jwt, user_jwt) if rt_jwt != ''
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

          puts "debug: issuer: #{issuer}"
          jwt_response['projectId'] = issuer.split('/').last # support both url issuer and project ID issuer

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

        def validate_token(token, _audience = nil)
          raise AuthException.new('Token validation received empty token', code: 500) if token.nil? || token.to_s.empty?

          unverified_header = jwt_get_unverified_header(token)
          alg_header = unverified_header[ALGORITHM_KEY]

          if alg_header.nil? || alg_header == 'none'
            raise AuthException.new('Token header is missing property: alg', code: 500)
          end

          kid = unverified_header['kid']
          raise AuthException.new('Token header is missing property: kid', code: 500) if kid.nil?

          if @public_keys.nil? || @public_keys == {} || @public_keys.to_s.empty? || @public_keys[kid].nil?
            fetch_public_keys
          end

          found_key = @public_keys[kid] || nil
          if found_key.nil?
            raise AuthException.new('Unable to validate public key. Public key not found.', code: 500)
          end

          # save reference to the founded key
          # (as another thread can change the self.public_keys hash)
          copy_key = found_key
          puts "debug: copy_key: #{copy_key}"
          alg_from_key = copy_key[1]
          if alg_header != alg_from_key
            raise AuthException.new(
              'Algorithm signature in JWT header does not match the algorithm signature in the public key',
              code: 500
            )
          end

          begin
            claims = JWT.decode(
              token,
              copy_key[0].public_key,
              true,
              { algorithm: alg_header, exp_leeway: @jwt_validation_leeway }
            )[0] # the payload is the first index in the decoded array
          rescue JWT::ExpiredSignature => e
            raise AuthException.new("Received Invalid token times error due to time glitch (between machines) during jwt validation, try to set the jwt_validation_leeway parameter (in DescopeClient) to higher value than 5sec which is the default: #{e.message}", code: 500)
          end
          puts "debug: claims: #{claims}"
          puts "debug: token: #{token}"
          claims['jwt'] = token
          claims
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
          puts "debug fetch_public_keys token_validation_v2 res: #{response}"
          unless response.is_a?(Hash) && response.key?('keys')
            raise AuthException.new("Unable to fetch public keys. #{response}", code: 500)
          end

          jwkeys_wrapper = response
          jwkeys = jwkeys_wrapper['keys']

          @public_keys = {}
          jwkeys.each do |key|
            loaded_kid, pub_key, alg = validate_and_load_public_key(key)
            @public_keys[loaded_kid] = [pub_key, alg]
          rescue AuthException
            nil
          end
          puts "debug fetch_public_keys @public_keys: #{@public_keys}"
          @public_keys
        end

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
        def validate_and_load_public_key(public_key)
          unless public_key.is_a?(String) || public_key.is_a?(Hash)
            raise AuthException.new(
              'Unable to load public key. Invalid public key error: (unknown type)',
              code: 500
            )
          end

          if public_key.is_a? String
            begin
              public_key = JSON.parse(public_key)
            rescue JSON::ParserError => e
              raise AuthException.new(
                "Unable to load public key. error: #{e.message}",
                code: 500
              )
            end
          end

          alg = public_key[ALGORITHM_KEY]
          if alg.nil?
            raise AuthException.new(
              'Unable to load public key. Missing property: alg',
              code: 500
            )
          end

          kid = public_key['kid']
          if kid.nil?
            raise AuthException.new(
              'Unable to load public key. Missing property: kid',
              code: 500
            )
          end

          begin
            # Load and validate public key
            [kid, JWT::JWK.new(public_key), alg]
          rescue JWT::JWKError => e
            raise AuthException.new(
              "Unable to load public key #{e.message}",
              code: 500
            )
          end
        end
      end
    end
  end
end
