# frozen_string_literal: true

require 'descope/mixins/common'
require 'descope/api/v1/auth/password'
require 'descope/api/v1/auth/enchantedlink'
require 'descope/api/v1/auth/magiclink'
require 'descope/api/v1/auth/oauth'
require 'descope/api/v1/auth/otp'
require 'descope/api/v1/auth/saml'
require 'descope/api/v1/auth/totp'

module Descope
  module Api
    module V1
      # Holds all the management API calls
      module Auth
        include Descope::Mixins::Common
        include Descope::Mixins::Common::EndpointsV1
        include Descope::Mixins::Common::EndpointsV2
        include Descope::Api::V1::Auth::Password
        include Descope::Api::V1::Auth::EnchantedLink
        include Descope::Api::V1::Auth::MagicLink
        include Descope::Api::V1::Auth::OAuth
        include Descope::Api::V1::Auth::OTP
        include Descope::Api::V1::Auth::SAML
        include Descope::Api::V1::Auth::TOTP


        ALGORITHM_KEY = 'alg'

        def generate_jwt_response(response_body: nil, refresh_cookie: nil, audience: nil)
          if response_body.nil? || response_body.empty?
            raise AuthException.new('Unable to generate jwt response. Response body is empty', code: 500)
          end

          jwt_response = generate_auth_info(response_body, refresh_cookie, true, audience)
          @logger.debug "jwt_response: #{jwt_response}"
          jwt_response['user'] = response_body.key?('user') ? response_body['user'] : {}
          jwt_response['firstSeen'] = response_body.key?('firstSeen') ? response_body['firstSeen'] : true

          jwt_response
        end

        def exchange_access_key(access_key: nil, login_options: {}, audience: nil)
          # Return a new session token for the given access key
          #   Args:
          #     access_key (str): The access key
          #     audience (str|Iterable[str]|nil): Optional recipients that the JWT is intended for
          #              (must be equal to the 'aud' claim on the provided token)
          #     login_options (hash): Optional advanced controls over login parameters
          #     Return value (Hash): returns the session token from the server together with the expiry and key id
          #                          (sessionToken:Hash, keyId:str, expiration:int)
          unless (access_key.is_a?(String) || access_key.nil?) && !access_key.to_s.empty?
            raise Descope::AuthException, 'Access key should be a string!'
          end

          res = post(EXCHANGE_AUTH_ACCESS_KEY_PATH, { loginOptions: login_options, audience: }, {}, access_key)
          generate_auth_info(res, nil, false, audience)
        end

        def select_tenant(tenant_id: nil, refresh_token: nil)
          validate_refresh_token_not_nil(refresh_token)
          res = post(SELECT_TENANT_PATH, { tenantId: tenant_id }, {}, refresh_token)
          @logger.debug "select_tenant response: #{res}"
          generate_jwt_response(
            response_body: res,
            refresh_cookie: res['refreshJwt']
          )
        end

        def validate_permissions(jwt_response: nil, permissions: nil)
          # Validate that a jwt_response has been granted the specified permissions.
          # For a multi-tenant environment use validate_tenant_permissions function
          validate_tenant_permissions(jwt_response:, permissions:)
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
        def validate_tenant_permissions(jwt_response: nil, tenant: nil, permissions: nil)
          # Validate that a jwt_response has been granted the specified permissions on the specified tenant.
          # For a multi-tenant environment use validate_tenant_permissions function
          if permissions.is_a?(String)
            permissions = [permissions]
          else
            permissions ||= []
          end

          unless jwt_response.is_a?(Hash)
            raise Descope::ArgumentException.new(
              'Invalid JWT response hash', code: 400
            )
          end

          return false unless jwt_response

          granted_permissions = if tenant.nil? || tenant.to_s.empty?
                                  jwt_response.fetch('permissions', [])
                                else
                                  # ensure that the tenant is associated with the jwt_response
                                  @logger.debug "tenant associated jwt: #{jwt_response['tenants']&.key?(tenant)}"
                                  return false unless jwt_response['tenants'].key?(tenant)

                                  # dig is a method in Ruby for safely navigating nested data structures like hashes
                                  # and arrays. It allows you to access deeply nested values without worrying about
                                  # raising an error if a middle value is nil.
                                  tenant_permission = jwt_response.dig('tenants', tenant, 'permissions') || []
                                  tenant_permission = [] if tenant_permission.nil?
                                  if tenant_permission.is_a?(String)
                                    @logger.debug "tenant_permission string: #{tenant_permission}"
                                    [tenant_permission]
                                  else
                                    @logger.debug "tenant_permission array: #{tenant_permission}"
                                    tenant_permission
                                  end
                                end

          # Validate all permissions are granted
          permissions.all? do |permission|
            granted_permissions.include?(permission)
          end
        end

        def validate_roles(jwt_response: nil, roles: nil)
          # Validate that a jwt_response has been granted the specified roles.
          # For a multi-tenant environment use validate_tenant_roles function
          validate_tenant_roles(jwt_response:, tenant: '', roles:)
        end

        def validate_tenant_roles(jwt_response: nil, tenant: nil, roles: nil)
          # Validate that a jwt_response has been granted the specified roles on the specified tenant.
          # For a multi-tenant environment use validate_tenant_roles function
          @logger.debug "Validate_tenant_roles: #{jwt_response}, #{tenant}, #{roles}"
          if roles.is_a?(String)
            roles = [roles]
          else
            roles ||= []
          end

          unless jwt_response.is_a?(Hash)
            raise Descope::ArgumentException.new(
              'Invalid JWT response hash', code: 400
            )
          end

          return false unless jwt_response

          granted_roles = if tenant.nil? || tenant.to_s.empty?
                            jwt_response.fetch('roles', [])
                          else
                            # ensure that the tenant is associated with the jwt_response
                            return false unless jwt_response['tenants'].key?(tenant)

                            # dig is a method in Ruby for safely navigating nested data structures like hashes
                            # and arrays. It allows you to access deeply nested values without worrying about
                            # raising an error if a middle value is nil.
                            tenant_roles = jwt_response.dig('tenants', tenant, 'roles') || []
                            tenant_roles = [] if tenant_roles.nil?
                            if tenant_roles.is_a?(String)
                              [tenant_roles]
                            else
                              tenant_roles
                            end
                          end

          @logger.debug "granted_roles: #{granted_roles}"
          # Validate all roles are granted
          roles.all? do |role|
            @logger.debug "granted_roles.include?(#{role}): #{granted_roles.include?(role)}"
            granted_roles.include?(role)
          end
        end

        def validate_token(token, _audience = nil)
          @logger.debug "validating token: #{token}"
          raise AuthException.new('Token validation received empty token', code: 500) if token.nil? || token.to_s.empty?

          unverified_header = jwt_get_unverified_header(token)
          @logger.debug "unverified_header: #{unverified_header}"
          alg_header = unverified_header[ALGORITHM_KEY]
          @logger.debug "alg_header: #{alg_header}"

          if alg_header.nil? || alg_header == 'none'
            raise AuthException.new('Token header is missing property: alg', code: 500)
          end

          kid = unverified_header['kid']
          @logger.debug "kid: #{kid}"
          raise AuthException.new('Token header is missing property: kid', code: 500) if kid.nil?

          found_key = nil
          @mlock.synchronize do
            if @public_keys.nil? || @public_keys == {} || @public_keys.to_s.empty? || @public_keys[kid].nil?
              @logger.debug 'fetching public keys'
              # fetch keys from /v2/keys and set them in @public_keys
              fetch_public_keys
            end

            found_key = @public_keys[kid]
            @logger.debug "found_key: #{found_key}"
            raise AuthException.new('Unable to validate public key. Public key not found.', code: 500) if found_key.nil?
          end

          # save reference to the found key
          # (as another thread can change the self.public_keys hash)
          @logger.debug 'checking if alg_header matches alg_from_key'
          alg_from_key = found_key[1]
          if alg_header != alg_from_key
            raise AuthException.new(
              'Algorithm signature in JWT header does not match the algorithm signature in the Public key.',
              code: 500
            )
          end

          begin
            @logger.debug 'decoding token'
            claims = JWT.decode(
              token,
              found_key[0].public_key,
              true,
              { algorithm: alg_header, exp_leeway: @jwt_validation_leeway }
            )[0] # the payload is the first index in the decoded array
          rescue JWT::ExpiredSignature => e
            raise AuthException.new(
              "Received Invalid token times error due to time glitch (between machines) during jwt validation, try to set the jwt_validation_leeway parameter (in DescopeClient) to higher value than 5sec which is the default: #{e.message}", code: 500
            )
          end
          claims['jwt'] = token
          @logger.debug "claims: #{claims}"
          claims
        end

        private

        def generate_auth_info(response_body, refresh_token, user_jwt, audience = nil)
          @logger.debug "generating auth info: #{response_body}, #{refresh_token}, #{user_jwt}, #{audience}"
          jwt_response = {}

          # validate the session token if sessionJwt is not empty
          st_jwt = response_body.fetch('sessionJwt', '')
          unless st_jwt.empty?
            @logger.debug "validating session token with refresh_token: #{refresh_token}" if st_jwt
            jwt_response[SESSION_TOKEN_NAME] = validate_token(st_jwt, audience) if st_jwt
          end

          # validate refresh token if refresh_token was passed or if refreshJwt is not empty
          rt_jwt = response_body.fetch('refreshJwt', '')

          if !refresh_token.nil? || !refresh_token.to_s.empty?
            @logger.debug "validating refresh token: #{refresh_token}" if refresh_token
            jwt_response[REFRESH_SESSION_TOKEN_NAME] = validate_token(refresh_token, audience)
          elsif !rt_jwt.empty?
            jwt_response[REFRESH_SESSION_TOKEN_NAME] = validate_token(rt_jwt, audience)
          end

          jwt_response = adjust_properties(jwt_response, user_jwt)

          if user_jwt
            jwt_response[COOKIE_DATA_NAME] = {
              exp: response_body.fetch('cookieExpiration', 0),
              maxAge: response_body.fetch('cookieMaxAge', 0),
              domain: response_body.fetch('cookieDomain', ''),
              path: response_body.fetch('cookiePath', '/')
            }
          end

          jwt_response
        end

        def adjust_properties(jwt_response, user_jwt)
          # Save permissions, roles and tenants info from Session token or from refresh token on the json top level
          if jwt_response[SESSION_TOKEN_NAME]
            jwt_response['permissions'] = jwt_response[SESSION_TOKEN_NAME].fetch('permissions', [])
            jwt_response['roles'] = jwt_response[SESSION_TOKEN_NAME].fetch('roles', [])
            jwt_response['tenants'] = jwt_response[SESSION_TOKEN_NAME].fetch('tenants', {})
          elsif jwt_response[REFRESH_SESSION_TOKEN_NAME]
            jwt_response['permissions'] = jwt_response[REFRESH_SESSION_TOKEN_NAME].fetch('permissions', [])
            jwt_response['roles'] = jwt_response[REFRESH_SESSION_TOKEN_NAME].fetch('roles', [])
            jwt_response['tenants'] = jwt_response[REFRESH_SESSION_TOKEN_NAME].fetch('tenants', {})
          else
            jwt_response['permissions'] = jwt_response.fetch('permissions', [])
            jwt_response['roles'] = jwt_response.fetch('roles', [])
            jwt_response['tenants'] = jwt_response.fetch('tenants', {})
          end

          # Save the projectID also in the dict top level
          issuer =
            jwt_response.fetch(SESSION_TOKEN_NAME, {}).fetch('iss', nil) ||
            jwt_response.fetch(REFRESH_SESSION_TOKEN_NAME, {}).fetch('iss', nil) ||
            jwt_response.fetch('iss', '')

          jwt_response['projectId'] = issuer.split('/').last # support both url issuer and project ID issuer

          sub =
            jwt_response.fetch(SESSION_TOKEN_NAME, {}).fetch('iss', nil) ||
            jwt_response.fetch(REFRESH_SESSION_TOKEN_NAME, {}).fetch('iss', nil) ||
            jwt_response.fetch('sub', '')

          if user_jwt
            jwt_response['userId'] = sub # Save the userID also in the dict top level
          else
            jwt_response['keyId'] = sub # Save the AccessKeyID also in the dict top level
          end

          jwt_response
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
          response = token_validation_key(@project_id)
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
                "Unable to parse public key json, error: #{e.message}",
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

        def validate_refresh_token_provided(login_options, refresh_token)
          refresh_required = !login_options.nil? && (login_options[:mfa] || login_options[:stepup])
          refresh_missing = refresh_token.nil? || refresh_token.to_s.empty?

          return unless refresh_required && refresh_missing

          raise AuthException.new(
            'Missing refresh token for stepup/mfa',
            code: 400
          )
        end

        def compose_url(base, method)
          suffix = get_method_string(method)
          unless suffix
            raise AuthException.new(
              "Unable to compose url. Unknown delivery method: #{method}",
              code: 500
            )
          end
          "#{base}/#{suffix}"
        end

        def get_login_id_by_method(method: nil, user: {})
          login_id = {
            DeliveryMethod::WHATSAPP => ['whatsapp', user.fetch(:phone, '')],
            DeliveryMethod::SMS => ['phone', user.fetch(:phone, '')],
            DeliveryMethod::EMAIL => ['email', user.fetch(:email, '')]
          }[method]

          raise AuthException.new("Unknown delivery method: #{method}", code: 400) if login_id.nil?

          login_id
        end

        def adjust_and_verify_delivery_method(method, login_id, user)
          return false if login_id.nil?

          return false unless user.is_a?(Hash)

          case method
          when DeliveryMethod::EMAIL
            user[:email] ||= login_id
            begin
              validate_email(user[:email])
              return true
            rescue AuthException
              return false
            end
          when DeliveryMethod::SMS
            user[:phone] ||= login_id
            return false unless /^#{PHONE_REGEX}$/.match(user[:phone])
          when DeliveryMethod::WHATSAPP
            user[:phone] ||= login_id
            return false unless /^#{PHONE_REGEX}$/.match(user[:phone])
          else
            return false
          end

          true
        end

        def extract_masked_address(response, method)
          if [DeliveryMethod::SMS, DeliveryMethod::WHATSAPP].include?(method)
            response['maskedPhone']
          elsif method == DeliveryMethod::EMAIL
            response['maskedEmail']
          else
            ''
          end
        end

        def exchange_token(uri, code)
          raise Descope::ArgumentException.new("Code can't be empty", code: 400) if code.nil? || code.empty?

          res = post(uri, { code: })
          generate_jwt_response(
            response_body: res,
            refresh_cookie: res['refreshJwt']
          )
        end
      end
    end
  end
end
