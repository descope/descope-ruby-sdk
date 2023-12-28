# frozen_string_literal: true

module Descope
  module Mixins
    # Module to provide validation for specific data structures.
    module Validation
      def validate_tenants(key_tenants)
        raise ArgumentError, 'key_tenants should be an Array of hashes' unless key_tenants.is_a? Array

        key_tenants.each do |tenant|
          unless tenant.is_a? Hash
            raise ArgumentError,
                  'Each tenant should be a Hash of tenant_id and optional role_names array'
          end

          tenant_symbolized = tenant.transform_keys(&:to_sym)

          raise ArgumentError, "Missing tenant_id key in tenant: #{tenant}" unless tenant_symbolized.key?(:tenant_id)
        end
      end

      def validate_login_id(login_id)
        raise AuthException, 'login_id cannot be empty' unless login_id.is_a?(String) && !login_id.empty?
      end

      def validate_password(password)
        raise AuthException, 'password cannot be empty' unless password.is_a?(String) && !password.empty?
      end

      def validate_token(token)
        decoding_error = 'token could not be decoded'
        raise Descope::InvalidToken, decoding_error unless !token.to_s.empty? && token.split('.').count == 3

        begin
          header = JWT::JSON.parse(JWT::Base64.url_decode(token.split('.').first))
        rescue Descope::AuthException => e
          raise Descope::InvalidToken.new("#{decoding_error} #{e}", code: 500) unless token.nil?
        end

        claims = decode_and_validate_signature(id_token, header)
        validate_claims(claims)
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
      def decode_and_validate_signature(id_token, header)
        algorithm = @context[:algorithm]

        unless algorithm.is_a?(JWTAlgorithm)
          raise Descope::InvalidToken, "Signature algorithm of \"#{algorithm}\" is not supported"
        end

        # The expiration verification will be performed in the validate_claims method
        options = { algorithms: [algorithm.name], verify_expiration: false, verify_not_before: false }
        secret = nil

        case algorithm
        when Descope::Algorithm::RS256
          kid = header['kid']
          jwks = JSON.parse(JSON[algorithm.jwks], symbolize_names: true)

          if !jwks[:keys].find { |key| key[:kid] == kid } && !algorithm.fetched_jwks?
            jwks = JSON.parse(JSON[algorithm.jwks(force: true)], symbolize_names: true)
          end

          options[:jwks] = jwks
        when Descope::Algorithm::HS256
          secret = algorithm.secret
        end

        begin
          result = JWT.decode(id_token, secret, true, options)
          result.first
        rescue JWT::VerificationError
          raise Descope::InvalidToken, 'Invalid ID token signature'
        rescue JWT::IncorrectAlgorithm
          alg = header['alg']
          raise Descope::InvalidToken, "Signature algorithm of \"#{alg}\" is not supported. Expected the ID token"\
            " to be signed with \"#{algorithm.name}\""
        rescue JWT::DecodeError
          raise Descope::InvalidToken, "Could not find a public key for Key ID (kid) \"#{kid}\""
        end
      end
      def validate_claims(claims)
        leeway = @context[:leeway]
        nonce = @context[:nonce]
        issuer = @context[:issuer]
        audience = @context[:audience]
        max_age = @context[:max_age]
        org = @context[:organization]

        raise Descope::InvalidParameter, 'Must supply a valid leeway' unless leeway.is_a?(Integer) && leeway >= 0
        raise Descope::InvalidParameter, 'Must supply a valid nonce' unless nonce.nil? || !nonce.to_s.empty?
        raise Descope::InvalidParameter, 'Must supply a valid issuer' unless issuer.nil? || !issuer.to_s.empty?
        raise Descope::InvalidParameter, 'Must supply a valid audience' unless audience.nil? || !audience.to_s.empty?
        raise Descope::InvalidParameter, 'Must supply a valid organization' unless org.nil? || !org.to_s.empty?

        unless max_age.nil? || (max_age.is_a?(Integer) && max_age >= 0)
          raise Descope::InvalidParameter, 'Must supply a valid max_age'
        end

        validate_iss(claims, issuer)
        validate_sub(claims)
        validate_aud(claims, audience)
        validate_exp(claims, leeway)
        validate_iat(claims, leeway)
        validate_nonce(claims, nonce) if nonce
        validate_azp(claims, audience) if claims['aud'].is_a?(Array) && claims['aud'].count > 1
        validate_auth_time(claims, max_age, leeway) if max_age
        validate_org(claims, org) if org
      end

      def validate_iss(claims, expected)
        unless claims.key?('iss') && claims['iss'].is_a?(String)
          raise Descope::InvalidToken, 'Issuer (iss) claim must be a string present in the ID token'
        end

        return if expected == claims['iss']

        raise Descope::InvalidToken, "Issuer (iss) claim mismatch in the ID token; expected \"#{expected}\","\
          " found \"#{claims['iss']}\""
      end

      def validate_sub(claims)
        return if claims.key?('sub') && claims['sub'].is_a?(String)

        raise Descope::InvalidToken, 'Subject (sub) claim must be a string present in the ID token'
      end

      def validate_aud(claims, expected)
        unless claims.key?('aud') && (claims['aud'].is_a?(String) || claims['aud'].is_a?(Array))
          raise Descope::InvalidToken, 'Audience (aud) claim must be a string or array of strings present'\
            ' in the ID token'
        end

        if claims['aud'].is_a?(String) && expected != claims['aud']
          raise Descope::InvalidToken, "Audience (aud) claim mismatch in the ID token; expected \"#{expected}\","\
            " found \"#{claims['aud']}\""
        elsif claims['aud'].is_a?(Array) && !claims['aud'].include?(expected)
          raise Descope::InvalidToken, "Audience (aud) claim mismatch in the ID token; expected \"#{expected}\""\
            " but was not one of \"#{claims['aud'].join ', '}\""
        end
      end

      def validate_exp(claims, leeway)
        unless claims.key?('exp') && claims['exp'].is_a?(Integer)
          raise Descope::InvalidToken, 'Expiration Time (exp) claim must be a number present in the ID token'
        end

        now = @context[:clock] || Time.now.to_i
        exp_time = claims['exp'] + leeway

        return if now < exp_time

        raise Descope::InvalidToken, 'Expiration Time (exp) claim mismatch in the ID token; current time'\
          " \"#{now}\" is after expiration time \"#{exp_time}\""
      end

      def validate_iat(claims, _leeway)
        return if claims.key?('iat') && claims['iat'].is_a?(Integer)

        raise Descope::InvalidToken, 'Issued At (iat) claim must be a number present in the ID token'
      end

      def validate_nonce(claims, expected)
        unless claims.key?('nonce') && claims['nonce'].is_a?(String)
          raise Descope::InvalidToken, 'Nonce (nonce) claim must be a string present in the ID token'
        end

        return if expected == claims['nonce']

        raise Descope::InvalidToken, "Nonce (nonce) claim mismatch in the ID token; expected \"#{expected}\","\
          " found \"#{claims['nonce']}\""
      end

      def validate_org(claims, expected)
        validate_as_id = expected.start_with? 'org_'

        if validate_as_id
          unless claims.key?('org_id') && claims['org_id'].is_a?(String)
            raise Descope::InvalidToken, 'Organization Id (org_id) claim must be a string present in the ID token'
          end

          unless expected == claims['org_id']
            raise Descope::InvalidToken, "Organization Id (org_id) claim value mismatch in the ID token; expected \"#{expected}\","\
              " found \"#{claims['org_id']}\""
          end
        else
          unless claims.key?('org_name') && claims['org_name'].is_a?(String)
            raise Descope::InvalidToken, 'Organization Name (org_name) claim must be a string present in the ID token'
          end

          unless expected.downcase == claims['org_name']
            raise Descope::InvalidToken, "Organization Name (org_name) claim value mismatch in the ID token; expected \"#{expected}\","\
              " found \"#{claims['org_name']}\""
          end
        end
      end

      def validate_azp(claims, expected)
        unless claims.key?('azp') && claims['azp'].is_a?(String)
          raise Descope::InvalidToken, 'Authorized Party (azp) claim must be a string present in the ID token'
        end

        return if expected == claims['azp']

        raise Descope::InvalidToken, 'Authorized Party (azp) claim mismatch in the ID token; expected'\
          " \"#{expected}\", found \"#{claims['azp']}\""
      end

      def validate_auth_time(claims, max_age, leeway)
        unless claims.key?('auth_time') && claims['auth_time'].is_a?(Integer)
          raise Descope::InvalidToken, 'Authentication Time (auth_time) claim must be a number present in the ID'\
            ' token when Max Age (max_age) is specified'
        end

        now = @context[:clock] || Time.now.to_i
        auth_valid_until = claims['auth_time'] + max_age + leeway

        return if now < auth_valid_until

        raise Descope::InvalidToken, 'Authentication Time (auth_time) claim in the ID token indicates that too'\
          ' much time has passed since the last end-user authentication. Current time'\
          " \"#{now}\" is after last auth at \"#{auth_valid_until}\""
      end
    end
  end
end
