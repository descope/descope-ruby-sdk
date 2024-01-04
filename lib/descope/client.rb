module Descope
  # Main class for descope client
  class Client
    include Descope::Mixins
    include Descope::Mixins::Common::EndpointsV1

    def logout(refresh_token: nil)
      # Logout user from current session and revoke the refresh_token. After calling this function,
      # you must invalidate or remove any cookies you have created.
      raise Descope::AuthException.new('signed refresh token {refresh_token} is empty', code: 400) if refresh_token.nil?

      post(LOGOUT_PATH, {}, {}, refresh_token)
    end

    def logout_all(refresh_token: nil)
      # Logout user from all sessions and revoke the refresh_token. After calling this function,
      # you must invalidate or remove any cookies you have created.
      raise Descope::AuthException.new('signed refresh token {refresh_token} is empty', code: 400) if refresh_token.nil?

      post(LOGOUT_ALL_PATH, {}, {}, refresh_token)
    end

    def me(refresh_token: nil)
      #  Retrieve user details for the refresh token. The returned data includes email, name, phone,
      # list of loginIds and boolean flags for verifiedEmail, verifiedPhone.
      raise Descope::AuthException.new('signed refresh token {refresh_token} is empty', code: 400) if refresh_token.nil?

      get(ME_PATH, {}, {}, refresh_token)
    end

  end
end
