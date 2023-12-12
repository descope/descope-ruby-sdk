require 'uri'
require 'net/http'
require_relative '../exception.rb'

module Descope
  module Mixins
    # HTTP-related methods
    module HTTP
      %i[get].each do  |method |
        define_method(method) do |uri, body = {}, pswd, extra_headers|
          body = body.delete_if { |_, v| v.nil? }
          request(method, uri, body, extra_headers)
        end

        def add_headers(h = {})
          raise ArgumentError, 'Headers must be an object which responds to #to_hash' unless h.respond_to?(:to_hash)
          @headers ||= {}
          @headers.merge!(h.to_hash)
        end
      end
    end
  end
end
