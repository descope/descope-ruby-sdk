# frozen_string_literal: true
require 'descope/mixins/common'
require 'addressable/uri'
require 'retryable'
require_relative '../exception'

module Descope
  module Mixins
    # HTTP-related methods
    module HTTP
      include Descope::Mixins::Common
      attr_accessor :headers, :base_uri, :timeout, :retry_count

      DEFAULT_RETRIES = 3
      MAX_ALLOWED_RETRIES = 10
      MAX_REQUEST_RETRY_JITTER = 250
      MAX_REQUEST_RETRY_DELAY = 1000
      MIN_REQUEST_RETRY_DELAY = 250
      BASE_DELAY = 100

      %i[get post post_file post_form put patch delete delete_with_body].each do |method|
        define_method(method) do |uri, body = {}, extra_headers = {}, pswd = nil|
          body = body.delete_if { |_, v| v.nil? }
          authorization_header(pswd) # This will set the pswd if provided, else default to the @default_pswd

          @logger.debug "request => method: #{method}, uri: #{uri}, body: #{body}, extra_headers: #{extra_headers}}"
          request_with_retry(method, uri, body, extra_headers)
        end
      end

      def retry_options
        sleep_timer = lambda do |attempt|
          wait = BASE_DELAY * (2**attempt - 1) # Exponential delay with each subsequent request attempt.
          wait += rand(wait + 1..wait + MAX_REQUEST_RETRY_JITTER) # Add jitter to the delay window.
          wait = [MAX_REQUEST_RETRY_DELAY, wait].min # Cap delay at MAX_REQUEST_RETRY_DELAY.
          wait = [MIN_REQUEST_RETRY_DELAY, wait].max # Ensure delay is no less than MIN_REQUEST_RETRY_DELAY.
          wait / 1000.to_f.round(2) # convert ms to seconds
        end

        tries = 1 + [Integer(retry_count || DEFAULT_RETRIES), MAX_ALLOWED_RETRIES].min # Cap retries at MAX_ALLOWED_RETRIES

        {
          tries: tries,
          sleep: sleep_timer,
          on: Descope::RateLimitException
        }
      end

      def safe_parse_json(body, cookies: {}, headers: {})
        @logger.debug "response => #{JSON.parse(body.to_s)}"
        res = JSON.parse(body.to_s)

        # Handle DS and DSR cookies in response.
        # First check RestClient's cookies (works for same-domain cookies)
        extracted_cookies = {}
        if cookies.key?(SESSION_COOKIE_NAME)
          extracted_cookies[SESSION_COOKIE_NAME] = cookies[SESSION_COOKIE_NAME]
        end
        if cookies.key?(REFRESH_SESSION_COOKIE_NAME)
          extracted_cookies[REFRESH_SESSION_COOKIE_NAME] = cookies[REFRESH_SESSION_COOKIE_NAME]
        end

        # If no cookies found via RestClient, parse Set-Cookie headers directly
        # This handles custom domain cookies that RestClient filters out
        if extracted_cookies.empty? && headers.respond_to?(:[])
          set_cookie_headers = headers[:set_cookie] || headers['set-cookie'] || headers['Set-Cookie'] || []
          set_cookie_headers = [set_cookie_headers] unless set_cookie_headers.is_a?(Array)

          set_cookie_headers.each do |cookie_header|
            next unless cookie_header.is_a?(String)
            
            # Parse DS cookie (session token)
            if cookie_header.include?("#{SESSION_COOKIE_NAME}=")
              cookie_value = parse_cookie_value(cookie_header, SESSION_COOKIE_NAME)
              extracted_cookies[SESSION_COOKIE_NAME] = cookie_value if cookie_value
            end
            
            # Parse DSR cookie (refresh token)
            if cookie_header.include?("#{REFRESH_SESSION_COOKIE_NAME}=")
              cookie_value = parse_cookie_value(cookie_header, REFRESH_SESSION_COOKIE_NAME)
              extracted_cookies[REFRESH_SESSION_COOKIE_NAME] = cookie_value if cookie_value
            end
          end
        end

        # Add extracted cookies to response if any were found
        unless extracted_cookies.empty?
          res['cookies'] = extracted_cookies
        end

        res
      rescue JSON::ParserError
        body
      end

      def parse_cookie_value(cookie_header, cookie_name)
        # Extract cookie value from Set-Cookie header
        # Format: "cookieName=cookieValue; attribute1=value1; attribute2=value2"
        # Only match valid cookie value characters (RFC 6265: exclude whitespace, semicolon, comma)
        match = cookie_header.match(/#{Regexp.escape(cookie_name)}=([^;]+)/)
        match ? match[1].strip : nil
      end

      def encode_uri(uri)
        encoded_uri = base_uri ? Addressable::URI.parse(uri).normalize : Addressable::URI.escape(uri)
        @logger.debug "will call #{url(encoded_uri)}"
        url(encoded_uri)
      end

      def url(path)
        "#{@base_uri}#{path}"
      end

      def add_headers(h = {})
        raise ArgumentError, 'Headers must be an object which responds to #to_hash' unless h.respond_to?(:to_hash)

        @headers ||= {}
        @headers.merge!(h.to_hash)
      end

      def request_with_retry(method, uri, body = {}, extra_headers = {}, pswd = nil)
        Retryable.retryable(retry_options) do
          request(method, uri, body, extra_headers)
        end
      end

      def request(method, uri, body = {}, extra_headers = {})
        # Only add license header for management API requests (not auth requests)
        if @license_type && uri.to_s.include?('/mgmt/')
          @headers['x-descope-license'] = @license_type
        else
          @headers.delete('x-descope-license')
        end

        # @headers is getting the authorization header merged in initializer.rb
        headers_debug = @headers.dup
        if headers_debug['Authorization']
          headers_debug['Authorization'] = headers_debug['Authorization'].gsub(/(.{10})\z/, '***********')
        end

        @logger.debug "base url: #{@base_uri}"
        @logger.debug "request method: #{method}, uri: #{uri}, body: #{body}, extra_headers: #{extra_headers}, headers: #{headers_debug}"
        result = case method
                 when :get
                   get_headers = @headers.merge({ params: body }).merge(extra_headers)
                   call(:get, encode_uri(uri), timeout, get_headers)
                 when :delete
                   delete_headers = @headers.merge({ params: body })
                   call(:delete, encode_uri(uri), timeout, delete_headers)
                 else
                   call(method, encode_uri(uri), timeout, @headers, body.to_json)
                 end

        raise Descope::Unsupported.new('No response from server', code: 400) unless result.respond_to?(:code)

        @logger.info("API Request: [#{method}] #{uri} - Response Code: #{result.code}")

        case result.code
        when 200...226 then safe_parse_json(result.body, cookies: result.cookies, headers: result.headers)
        when 400       then raise Descope::BadRequest.new(result.body, code: result.code, headers: result.headers)
        when 401       then raise Descope::Unauthorized.new(result.body, code: result.code, headers: result.headers)
        when 403       then raise Descope::AccessDenied.new(result.body, code: result.code, headers: result.headers)
        when 404       then raise Descope::NotFound.new(result.body, code: result.code, headers: result.headers)
        when 405       then raise Descope::MethodNotAllowed.new(result.body, code: result.code, headers: result.headers)
        when 429       then raise Descope::RateLimitException.new(result.body, code: result.code, headers: result.headers)
        when 500       then raise Descope::ServerError.new(result.body, code: result.code, headers: result.headers)
        else
          raise Descope::Unsupported.new(result.body, code: result.code, headers: result.headers)
        end
      end

      def call(method, url, timeout, headers, body = nil)
        RestClient::Request.execute(
          method: method,
          url: url,
          timeout: timeout,
          headers: headers,
          payload: body
        )
      rescue RestClient::Exception => e
        case e
        when RestClient::RequestTimeout
          raise Descope::RequestTimeout.new(e.message)
        else
          return e.response
        end
      end
    end
  end
end

