# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Role do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
    @client.logger.info('Staring cleanup before tests...')
    @client.logger.info('Deleting all permissions for Ruby SDK...')
    @client.load_all_permissions['permissions'].each do |perm|
      if perm['description'] =~ /Ruby SDK/
        @client.logger.info("Deleting permission: #{perm['name']}")
        @client.delete_permission(perm['name'])
      end
    end

    @client.logger.info('Deleting all roles for Ruby SDK...')
    @client.load_all_roles['roles'].each do |role|
      puts "got role: #{role}"
      if role['description'] == 'Ruby SDK'
        @client.logger.info("Deleting role: #{role['name']}")
        @client.delete_role(name: role['name'], tenant_id: role['tenantId'])
      end
    end

    @client.logger.info('Deleting all tenants for Ruby SDK...')
    @client.search_all_tenants(names: ['Ruby-SDK-test'])['tenants'].each do |tenant|
      @client.logger.info("Deleting tenant: #{tenant['name']}")
      @client.delete_tenant(tenant['id'])
    end
    @client.logger.info('Cleanup completed. Starting tests...')
  end

  it 'should create update and delete a role' do
    @client.logger.info('Testing role creation, update, deletion and search...')

    # Create permissions
    @client.logger.info('creating viewer permission for role')
    @client.create_permission(name: 'viewer', description: 'Viewer Permission Ruby SDK')

    @client.logger.info('creating editor permission for role')
    @client.create_permission(name: 'editor', description: 'Editor Permission Ruby SDK')

    @client.logger.info('creating admin permission for role')
    @client.create_permission(name: 'admin', description: 'Admin Permission Ruby SDK')

    # Create tenants
    @client.logger.info('creating Ruby-SDK-test tenant')
    tenant_id = @client.create_tenant(name: 'Ruby-SDK-test')['id']

    # Create roles
    @client.logger.info('creating Ruby-SDK-test role')
    @client.create_role(name: 'Ruby-SDK-test-viewer', description: 'Ruby SDK', permission_names: ['viewer'])
    @client.logger.info('creating Ruby-SDK-test-admin role')
    @client.create_role(name: 'Ruby-SDK-test-admin', description: 'Ruby SDK', permission_names: ['admin'], tenant_id:)

    # check all roles matching the correct permission
    @client.logger.info('check all roles matching the correct permission (load roles)')
    roles = @client.load_all_roles['roles']
    roles.each do |role|
      expect(role['permissionNames']).to include('viewer') if role['name'] == 'Ruby-SDK-test-viewer'
      expect(role['permissionNames']).to include('admin') if role['name'] == 'Ruby-SDK-test-admin'
    end

    @client.logger.info('updating role')
    @client.update_role(
      name: 'Ruby-SDK-test-viewer',
      new_name: 'Ruby-SDK-test-editor',
      description: 'Ruby SDK',
      permission_names: ['editor']
    )

    @client.logger.info('searching for roles by role names...')
    all_roles = @client.search_roles(role_names: %w[Ruby-SDK-test-admin Ruby-SDK-test-editor])['roles']
    expected_roles = %w[Ruby-SDK-test-editor Ruby-SDK-test-admin]
    role_count = 0
    expected_roles.each do |expected_role|
      expect(all_roles.map { |role| role['name'] }).to include(expected_role)
      role_count += 1
    end
    expect(role_count).to eq(2)

    @client.logger.info('searching for roles with role name like...')
    all_roles = @client.search_roles(role_name_like: 'Ruby-SDK-test')['roles']
    expected_roles = %w[Ruby-SDK-test-editor Ruby-SDK-test-admin]
    role_count = 0
    expected_roles.each do |expected_role|
      expect(all_roles.map { |role| role['name'] }).to include(expected_role)
      role_count += 1
    end

    expect(role_count).to eq(2)

    @client.logger.info('searching for roles with permission names...')
    all_roles = @client.search_roles(permission_names: %w[admin])['roles']
    expect(all_roles.map { |role| role['name'] }).to include('Ruby-SDK-test-admin')

    @client.logger.info('searching for roles with tenant ids...')
    all_roles = @client.search_roles(role_name_like: 'Ruby-SDK-test', tenant_ids: [tenant_id])['roles']
    expect(all_roles.map { |role| role['name'] }).to include('Ruby-SDK-test-admin')

    @client.logger.info('deleting permission')

    @client.delete_permission('editor')
    @client.delete_permission('admin')

    @client.logger.info('deleting editor role')
    @client.delete_role(name: 'Ruby-SDK-test-editor')

    @client.logger.info('deleting admin role')
    @client.delete_role(name: 'Ruby-SDK-test-admin', tenant_id:)

    @client.logger.info('deleting tenant')
    @client.delete_tenant(tenant_id)
  end
end
