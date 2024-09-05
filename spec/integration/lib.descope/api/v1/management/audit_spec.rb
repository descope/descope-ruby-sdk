# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Audit do
  before(:all) do
    raise 'DESCOPE_MANAGEMENT_KEY is not set' if ENV['DESCOPE_MANAGEMENT_KEY'].nil?

    @client = DescopeClient.new(Configuration.config)
    @client.logger.info('Deleting all tenants for Ruby SDK...')
    @client.search_all_tenants(names: ['Ruby-SDK-test'])['tenants'].each do |tenant|
      @client.logger.info("Deleting tenant: #{tenant['name']}")
      @client.delete_tenant(tenant['id'])
    end
    @client.logger.info('Cleanup completed. Starting tests...')
  end

  after(:all) do
    all_users = @client.search_all_users
    all_users['users'].each do |user|
      if user['middleName'] == 'Ruby SDK User'
        puts "Deleting ruby spec test user #{user['loginIds'][0]}"
        @client.delete_user(user['loginIds'][0])
      end
    end
  end

  it 'should search the audit trail for user operations' do
    res = @client.audit_search(actions: ['LoginSucceed'])
    expect(res).to be_a(Hash)
    expect(res['audits']).to be_a(Array)
  end

  it 'should create a new audit event' do
    # Create tenants
    @client.logger.info('creating Ruby-SDK-test tenant')
    tenant_id = @client.create_tenant(name: 'Ruby-SDK-test')['id']

    # Create a user (actor)
    user = build(:user)
    created_user = @client.create_user(**user)['user']

    expect do
      @client.audit_create_event(
        user_id: created_user['loginId'],
        action: 'pencil.created',
        type: 'info',
        tenant_id:,
        actor_id: created_user['loginIds'][0],
        data: { 'key' => 'value' }
      )
    end.not_to raise_error
  end
end
