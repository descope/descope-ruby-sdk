# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::OutboundApp do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::OutboundApp)
    @instance = dummy_instance
  end

  describe '.fetch_outbound_app_user_token' do
    let(:mock_response) do
      {
        'token' => {
          'id' => 'token-123',
          'appId' => 'app-123',
          'userId' => 'user-123',
          'tokenSub' => 'sub-123',
          'accessToken' => 'access-token-value',
          'accessTokenType' => 'Bearer',
          'accessTokenExpiry' => '2025-12-31T23:59:59Z',
          'hasRefreshToken' => true,
          'refreshToken' => 'refresh-token-value',
          'scopes' => %w[read write],
          'tenantId' => 'tenant-123'
        }
      }
    end

    it 'responds to fetch_outbound_app_user_token' do
      expect(@instance).to respond_to :fetch_outbound_app_user_token
    end

    it 'raises an error when app_id is empty' do
      expect do
        @instance.fetch_outbound_app_user_token(app_id: '', user_id: 'user-123')
      end.to raise_error(Descope::ArgumentException, 'app_id cannot be empty')
    end

    it 'raises an error when app_id is nil' do
      expect do
        @instance.fetch_outbound_app_user_token(app_id: nil, user_id: 'user-123')
      end.to raise_error(Descope::ArgumentException, 'app_id cannot be empty')
    end

    it 'raises an error when user_id is empty' do
      expect do
        @instance.fetch_outbound_app_user_token(app_id: 'app-123', user_id: '')
      end.to raise_error(Descope::ArgumentException, 'Missing user id')
    end

    it 'raises an error when user_id is nil' do
      expect do
        @instance.fetch_outbound_app_user_token(app_id: 'app-123', user_id: nil)
      end.to raise_error(Descope::ArgumentException, 'Missing user id')
    end

    it 'fetches token with required parameters only' do
      expect(@instance).to receive(:post).with(
        '/v1/mgmt/outbound/app/user/token',
        {
          appId: 'app-123',
          userId: 'user-123'
        }
      ).and_return(mock_response)

      result = @instance.fetch_outbound_app_user_token(app_id: 'app-123', user_id: 'user-123')
      expect(result['token']['accessToken']).to eq('access-token-value')
    end

    it 'fetches token with scopes' do
      expect(@instance).to receive(:post).with(
        '/v1/mgmt/outbound/app/user/token',
        {
          appId: 'app-123',
          userId: 'user-123',
          scopes: %w[read write]
        }
      ).and_return(mock_response)

      result = @instance.fetch_outbound_app_user_token(
        app_id: 'app-123',
        user_id: 'user-123',
        scopes: %w[read write]
      )
      expect(result['token']['scopes']).to eq(%w[read write])
    end

    it 'fetches token with options' do
      expect(@instance).to receive(:post).with(
        '/v1/mgmt/outbound/app/user/token',
        {
          appId: 'app-123',
          userId: 'user-123',
          options: {
            withRefreshToken: true,
            forceRefresh: true
          }
        }
      ).and_return(mock_response)

      result = @instance.fetch_outbound_app_user_token(
        app_id: 'app-123',
        user_id: 'user-123',
        with_refresh_token: true,
        force_refresh: true
      )
      expect(result['token']['hasRefreshToken']).to be(true)
    end

    it 'fetches token with tenant_id' do
      expect(@instance).to receive(:post).with(
        '/v1/mgmt/outbound/app/user/token',
        {
          appId: 'app-123',
          userId: 'user-123',
          tenantId: 'tenant-123'
        }
      ).and_return(mock_response)

      result = @instance.fetch_outbound_app_user_token(
        app_id: 'app-123',
        user_id: 'user-123',
        tenant_id: 'tenant-123'
      )
      expect(result['token']['tenantId']).to eq('tenant-123')
    end

    it 'fetches token with all parameters' do
      expect(@instance).to receive(:post).with(
        '/v1/mgmt/outbound/app/user/token',
        {
          appId: 'app-123',
          userId: 'user-123',
          scopes: %w[read write],
          tenantId: 'tenant-123',
          options: {
            withRefreshToken: true,
            forceRefresh: false
          }
        }
      ).and_return(mock_response)

      result = @instance.fetch_outbound_app_user_token(
        app_id: 'app-123',
        user_id: 'user-123',
        scopes: %w[read write],
        tenant_id: 'tenant-123',
        with_refresh_token: true,
        force_refresh: false
      )
      expect(result['token']['id']).to eq('token-123')
    end
  end

  describe '.delete_outbound_app_user_tokens' do
    it 'responds to delete_outbound_app_user_tokens' do
      expect(@instance).to respond_to :delete_outbound_app_user_tokens
    end

    it 'raises an error when both app_id and user_id are empty' do
      expect do
        @instance.delete_outbound_app_user_tokens(app_id: '', user_id: '')
      end.to raise_error(Descope::ArgumentException, 'At least one of app_id or user_id must be provided')
    end

    it 'raises an error when both app_id and user_id are nil' do
      expect do
        @instance.delete_outbound_app_user_tokens
      end.to raise_error(Descope::ArgumentException, 'At least one of app_id or user_id must be provided')
    end

    it 'deletes tokens by app_id only' do
      expect(@instance).to receive(:delete).with(
        '/v1/mgmt/outbound/user/tokens',
        { appId: 'app-123' }
      )

      expect do
        @instance.delete_outbound_app_user_tokens(app_id: 'app-123')
      end.not_to raise_error
    end

    it 'deletes tokens by user_id only' do
      expect(@instance).to receive(:delete).with(
        '/v1/mgmt/outbound/user/tokens',
        { userId: 'user-123' }
      )

      expect do
        @instance.delete_outbound_app_user_tokens(user_id: 'user-123')
      end.not_to raise_error
    end

    it 'deletes tokens by both app_id and user_id' do
      expect(@instance).to receive(:delete).with(
        '/v1/mgmt/outbound/user/tokens',
        { appId: 'app-123', userId: 'user-123' }
      )

      expect do
        @instance.delete_outbound_app_user_tokens(app_id: 'app-123', user_id: 'user-123')
      end.not_to raise_error
    end
  end

  describe '.delete_outbound_app_token_by_id' do
    it 'responds to delete_outbound_app_token_by_id' do
      expect(@instance).to respond_to :delete_outbound_app_token_by_id
    end

    it 'raises an error when token_id is empty' do
      expect do
        @instance.delete_outbound_app_token_by_id(token_id: '')
      end.to raise_error(Descope::ArgumentException, 'token_id cannot be empty')
    end

    it 'raises an error when token_id is nil' do
      expect do
        @instance.delete_outbound_app_token_by_id(token_id: nil)
      end.to raise_error(Descope::ArgumentException, 'token_id cannot be empty')
    end

    it 'deletes token by id' do
      expect(@instance).to receive(:delete).with(
        '/v1/mgmt/outbound/token',
        { id: 'token-123' }
      )

      expect do
        @instance.delete_outbound_app_token_by_id(token_id: 'token-123')
      end.not_to raise_error
    end
  end
end
