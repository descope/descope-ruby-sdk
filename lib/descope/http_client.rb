# frozen_string_literal: true

require 'descope/mixins/http'

module Descope
  # Performs the SDK's HTTP calls. One instance is created per kind of request so that the two
  # management keys are never sent together: the management client carries the management key, the
  # authentication client carries the auth management key.
  class HttpClient
    include Descope::Mixins::HTTP

    def initialize(base_uri:, project_id:, headers:, logger:, key: nil, timeout: nil, retry_count: nil)
      @base_uri = base_uri
      @project_id = project_id
      @key = key
      @headers = headers.dup
      @logger = logger
      @timeout = timeout
      @retry_count = retry_count
    end

    # Bearer <project_id>[:<pswd>][:<key>] where pswd is a refresh token or access key presented by
    # the caller and key is this client's management key. Blank parts are skipped, so callers do
    # not have to branch on what happens to be configured.
    def authorization_header(pswd = nil)
      bearer = [@project_id, pswd, @key].reject { |part| part.nil? || part.to_s.empty? }.join(':')
      { 'Authorization' => "Bearer #{bearer}" }
    end
  end
end
