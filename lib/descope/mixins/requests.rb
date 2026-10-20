# frozen_string_literal: true

require 'descope/mixins/http'

module Descope
  module Mixins
    # Routes an API call to the HTTP client that holds the right key: the bare verbs serve the
    # authentication APIs and go out with the auth management key, the mgmt_ prefixed verbs serve
    # the management APIs and go out with the management key.
    module Requests
      attr_reader :auth_http, :mgmt_http

      Descope::Mixins::HTTP::HTTP_METHODS.each do |method|
        define_method(method) do |*args|
          @auth_http.public_send(method, *args)
        end

        define_method(:"mgmt_#{method}") do |*args|
          @mgmt_http.public_send(method, *args)
        end
      end
    end
  end
end
