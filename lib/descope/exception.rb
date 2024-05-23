module Descope
  # Default exception in namespace of Descope
  # If you want to catch all exceptions, then you should use this one.
  # Network exceptions are not included
  class Exception < StandardError
    attr_reader :error_data

    def initialize(message, error_data = {})
      super(message)
      @error_data = error_data
    end
  end

  # Parent for all exceptions that arise out of HTTP error responses.
  class HTTPError < Descope::Exception
    def headers
      error_data[:headers]
    end

    def http_code
      error_data[:code]
    end
  end

  class AuthException < Descope::Exception; end
  # exception for unauthorized requests, if you see it,
  # probably Bearer Token is not set correctly

  # exception for unset user_id, this might cause removal of
  # all users, or other unexpected behaviour
  class ArgumentException < Descope::Exception; end

  # exception for invalid token when its empty
  class InvalidToken < Descope::Exception; end
  class InvalidParameter < Descope::Exception; end
  class Unauthorized < Descope::HTTPError; end
  # exception for not found resource, you query for an
  # non-existent resource, or wrong path
  class NotFound < Descope::HTTPError; end
  class MethodNotAllowed < Descope::HTTPError; end
  # exception for unknown error
  class Unsupported < Descope::HTTPError; end
  # exception for server error
  class ServerError < Descope::HTTPError; end
  # exception for incorrect request, you've sent wrong params
  class BadRequest < Descope::HTTPError; end
  class AccessDenied < Descope::HTTPError; end
  class RateLimitException < Descope::HTTPError; end
  class RequestTimeout < Descope::HTTPError; end

  # exception for nOTP authorization
  class ErrNOTPUnauthorized < Descope::AuthException; end
end
