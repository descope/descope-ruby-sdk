# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Auth do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Auth)
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Mixins::Common::EndpointsV1)
    @instance = dummy_instance
  end

  context '.generate_jwt_response' do
    it 'is expected to respond to generate jwt response' do
      expect(@instance).to respond_to(:generate_jwt_response)
    end

    let(:response_body) do
      {
        'sessionJwt' => 'eyJhbGciOiJSUzI1NiIsImtpZCI6IlNLMlpvS2kyUTRJNVU4U2phbWabcd9YUld2S2wwIiwidHlwIjoiSldUIn0.eyJhbXIiOlsicHdkIl0sImRybiI6IkRTIiwiZXhwIjoxNzAzODE1NzgwLCJpYXQiOjE3MDM4MTUxODAsImlzcyI6IlAyWm9LaHpBZHZaVjlIelJaMFNFOHBJZE5xOFAiLCJyZXhwIjoiMjAyNC0wMS0yNlQwMTo1OTo0MFoiLCJzdWIiOiJVMmFCallQOTY3dDU0b3lOeGxuaHhDUlFlWmw2In0.HX3wGlV_xInKiqbKzlXBHDvq2oH-UoJjD0gLjd-6mbJJRXhF4tyAgDrhvhbjY0k1SclIvYZxvsdB5UBlSXN_hY5j6N3UCbcXH9wsHu1E8Wlsmv9pb9OUUFJc4YoDEFGbu1wbACL47WYG8R4BGFqC2GpbT7gyamSyW-UlPkkHOPGpf6-jfFeW7yTbVk4sVAURXn8EHT9zlPzuKfQpejq_JPpwR5QrO_eH0Ho5F38maNZe_eopFKH7QDQQFyrKAq-ePdiD7h4Upe46EaUv1i-nuXrfTuffd7riIeIBrsSzhIIH47qk1fU6ak3NMO-jWJZypU7sPCBl_aVpAP5lct7M-g', 'refreshJwt' => 'eyJhbGciOiJSUzI1NiIsImtpZCI6IlNLMlpvS2kyUTRJNVU4U2phbW1UeU9YUld2S2wwIiwidHlwIjoiSldUIn0.eyJhbXIiOlsicHdkIl0sImRybiI6IkRTUiIsImV4cCI6MTcwNjIzNDM4MCwiaWF0IjoxNzAzODE1MTgwLCJpc3MiOiJQMlpvS2h6QWR2WlY5SHpSWjBTRThwSWROcThQIiwic3ViIjoiVTJhQmpZUDk2N3Q1NG95Tnhsbmh4Q1JRZVpsNiJ9.KHS41ik6YPu0tvdhxCFcunAu8uF5EAMkOa61-7PercYWY6rLH1QN4M-gPABA6qGNLbgyFmOber2bMF2R_kMGYlsCFSncZbdNWg5mzfixBQ0KaF2_RLYtfywzXbNyegP4Kt_EwG6Yszr1Xy7suE__edjFYRCzWWrxlQdYFt0JfJkO9z571XHSKP-xMF1wWH8oQiBsUgQI0-1aOVhG0K6V073VFM-8sjxAZK6YNsPgZlUKxj766-eRyj1kY0EYNA7_GW5tI4nAlNJE53A8KhTz01APZEM8HjdZpFEqzKbwZ9-__pHhluKCt4vcnPe0s9ExIlyIA_n_F8OKAg8121taRg', 'cookieDomain' => '', 'cookiePath' => '/', 'cookieMaxAge' => 2_419_199, 'cookieExpiration' => 1_706_234_380, 'user' => {
          'loginIds' => ['tester@descope.com'], 'userId' => 'U2aBjYP967t54oyNxlnhxCRQeZl6', 'name' => 'Itzik', 'email' => 'tester@descope.com', 'phone' => '+12122299988', 'verifiedEmail' => false, 'verifiedPhone' => false, 'roleNames' => [], 'userTenants' => [], 'status' => 'enabled', 'externalIds' => ['tester@descope.com'], 'picture' => '', 'test' => false, 'customAttributes' => {}, 'createdTime' => 1_703_798_912, 'TOTP' => false, 'SAML' => false, 'OAuth' => {}, 'webauthn' => false, 'password' => true, 'ssoAppIds' => [], 'givenName' => '', 'middleName' => '', 'familyName' => ''
        }, 'firstSeen' => false
      }
    end

    it 'is expected to generate jwt response' do
      allow(@instance).to receive(:token_validation_v2).and_return(
        {
          'keys' => [
            {
              'alg' => 'RS256',
              'e' => 'AQAB',
              'kid' => 'SK2ZoKi2Q4I5U8SjammTyOXRWvKl0',
              'kty' => 'RSA',
              'n' => 'shNRO_U_ ',
              'use' => 'sig'
            }
          ]
        }
      )
      expect do
        @instance.generate_jwt_response(response_body)
      end.not_to raise_error
    end

  end
end
