# frozen_string_literal: true

require 'spec_helper'

# Covers the Authorization header the SDK actually sends. The auth management key rides along with
# every authentication request so that methods whose public access has been disabled can still be
# used, and it is never sent on management requests - those carry the management key instead.
describe 'auth management key' do
  let(:project_id) { 'P2abcde12345' }
  let(:management_key) { 'mgmt-key' }
  let(:auth_management_key) { 'auth-key' }
  let(:refresh_token) { 'refresh-token' }

  # Stubs the RestClient boundary on both of the client's HTTP clients and hands back the
  # Authorization header of whichever one ends up being used.
  def authorization_for(client)
    captured = nil
    [client.auth_http, client.mgmt_http].each do |http|
      allow(http).to receive(:call) do |_method, _url, _timeout, headers, _body|
        captured = headers['Authorization']
        double('response', code: 200, body: '{}', cookies: {}, headers: {})
      end
    end
    yield
    captured
  end

  def build_client(**options)
    Descope::Client.new({ project_id: project_id, log_level: 'fatal' }.merge(options))
  end

  # An authentication request that presents no token of its own.
  def sign_up(client)
    client.otp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: 'someone@example.com')
  end

  around do |example|
    keys = %w[DESCOPE_MANAGEMENT_KEY DESCOPE_AUTH_MANAGEMENT_KEY]
    saved = keys.to_h { |var| [var, ENV[var]] }
    keys.each { |var| ENV.delete(var) }
    example.run
  ensure
    saved.each { |var, value| ENV[var] = value }
  end

  context 'on authentication requests' do
    it 'sends only the project ID when no auth management key is configured' do
      client = build_client
      header = authorization_for(client) { sign_up(client) }
      expect(header).to eq("Bearer #{project_id}")
    end

    it 'appends the auth management key when one is configured' do
      client = build_client(auth_management_key: auth_management_key)
      header = authorization_for(client) { sign_up(client) }
      expect(header).to eq("Bearer #{project_id}:#{auth_management_key}")
    end

    it 'appends the auth management key after a refresh token' do
      client = build_client(auth_management_key: auth_management_key)
      header = authorization_for(client) { client.me(refresh_token) }
      expect(header).to eq("Bearer #{project_id}:#{refresh_token}:#{auth_management_key}")
    end

    it 'never sends the management key' do
      client = build_client(management_key: management_key, auth_management_key: auth_management_key)
      header = authorization_for(client) { sign_up(client) }
      expect(header).to eq("Bearer #{project_id}:#{auth_management_key}")
      expect(header).to_not include(management_key)
    end

    # DummyClass swallows extra_headers, so only a real client exercises this argument.
    it 'tolerates a nil extra_headers from the caller' do
      client = build_client(auth_management_key: auth_management_key)
      header = authorization_for(client) { client.post(SIGN_IN_PASSWORD_PATH, {}, nil, refresh_token) }
      expect(header).to eq("Bearer #{project_id}:#{refresh_token}:#{auth_management_key}")
    end

    it 'signs in with an enchanted link' do
      client = build_client(auth_management_key: auth_management_key)
      header = authorization_for(client) do
        client.enchanted_link_sign_in(login_id: 'someone@example.com', uri: 'https://example.com')
      end
      expect(header).to eq("Bearer #{project_id}:#{auth_management_key}")
    end

    it 'does not substitute a key for an empty refresh token' do
      client = build_client(management_key: management_key, auth_management_key: auth_management_key)
      header = authorization_for(client) { client.sign_out('') }
      expect(header).to eq("Bearer #{project_id}:#{auth_management_key}")
    end
  end

  context 'on management requests' do
    it 'appends the management key' do
      client = build_client(management_key: management_key)
      header = authorization_for(client) { client.load_all_tenants }
      expect(header).to eq("Bearer #{project_id}:#{management_key}")
    end

    it 'never sends the auth management key' do
      client = build_client(management_key: management_key, auth_management_key: auth_management_key)
      header = authorization_for(client) { client.load_all_tenants }
      expect(header).to eq("Bearer #{project_id}:#{management_key}")
      expect(header).to_not include(auth_management_key)
    end

    it 'sends only the project ID when no management key is configured' do
      client = build_client(auth_management_key: auth_management_key)
      header = authorization_for(client) { client.load_all_tenants }
      expect(header).to eq("Bearer #{project_id}")
    end
  end

  context 'configuration' do
    it 'falls back to the DESCOPE_AUTH_MANAGEMENT_KEY env var' do
      ENV['DESCOPE_AUTH_MANAGEMENT_KEY'] = 'env-auth-key'
      client = build_client
      header = authorization_for(client) { sign_up(client) }
      expect(header).to eq("Bearer #{project_id}:env-auth-key")
    end

    it 'prefers the configured key over the env var' do
      ENV['DESCOPE_AUTH_MANAGEMENT_KEY'] = 'env-auth-key'
      client = build_client(auth_management_key: auth_management_key)
      header = authorization_for(client) { sign_up(client) }
      expect(header).to eq("Bearer #{project_id}:#{auth_management_key}")
    end

    it 'keeps the two keys distinct' do
      ENV['DESCOPE_MANAGEMENT_KEY'] = management_key
      ENV['DESCOPE_AUTH_MANAGEMENT_KEY'] = auth_management_key
      client = build_client
      expect(client.auth_http.authorization_header).to eq(
        { 'Authorization' => "Bearer #{project_id}:#{auth_management_key}" }
      )
      expect(client.mgmt_http.authorization_header).to eq(
        { 'Authorization' => "Bearer #{project_id}:#{management_key}" }
      )
    end
  end

  describe 'debug logging' do
    it 'masks everything after the project ID' do
      client = build_client(auth_management_key: auth_management_key)
      masked = client.auth_http.mask_authorization(client.auth_http.authorization_header)
      expect(masked['Authorization']).to eq("Bearer #{project_id}:***")
      expect(masked['Authorization']).to_not include(auth_management_key)
    end
  end
end
