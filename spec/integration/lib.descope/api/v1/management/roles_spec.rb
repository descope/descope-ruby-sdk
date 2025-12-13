# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Role do
  before(:all) do
    raise 'DESCOPE_MANAGEMENT_KEY is not set' if ENV['DESCOPE_MANAGEMENT_KEY'].nil?

    @client = DescopeClient.new(Configuration.config)
    @test_prefix = SpecUtils.build_prefix
    @client.logger.info("Starting cleanup before tests with prefix: #{@test_prefix}...")
    
    # Define resource names with unique prefix for parallel execution
    @permission_viewer = "#{@test_prefix}viewer"
    @permission_editor = "#{@test_prefix}editor"
    @permission_admin = "#{@test_prefix}admin"
    @role_viewer = "#{@test_prefix}Ruby-SDK-test-viewer"
    @role_editor = "#{@test_prefix}Ruby-SDK-test-editor"
    @role_admin = "#{@test_prefix}Ruby-SDK-test-admin"
    @tenant_name = "#{@test_prefix}Ruby-SDK-test"
    @description = "#{@test_prefix}Ruby SDK"
    
    # Cleanup any leftover resources from previous failed runs
    @client.logger.info('Deleting all permissions for this test run...')
    @client.load_all_permissions['permissions'].each do |perm|
      if perm['description'] == @description
        @client.logger.info("Deleting permission: #{perm['name']}")
        @client.delete_permission(perm['name'])
      end
    end

    @client.logger.info('Deleting all roles for this test run...')
    @client.load_all_roles['roles'].each do |role|
      if role['description'] == @description
        @client.logger.info("Deleting role: #{role['name']}")
        @client.delete_role(name: role['name'], tenant_id: role['tenantId'])
      end
    end

    @client.logger.info('Deleting all tenants for this test run...')
    @client.search_all_tenants(names: [@tenant_name])['tenants'].each do |tenant|
      @client.logger.info("Deleting tenant: #{tenant['name']}")
      @client.delete_tenant(tenant['id'])
    end
    @client.logger.info('Cleanup completed. Starting tests...')
  end
  
  after(:all) do
    # Cleanup after tests to ensure no resources are left behind
    @client.logger.info('Cleaning up test resources...')
    
    begin
      @client.delete_permission(@permission_viewer) if defined?(@permission_viewer)
    rescue StandardError => e
      @client.logger.info("Permission #{@permission_viewer} already deleted or doesn't exist: #{e.message}")
    end
    
    begin
      @client.delete_permission(@permission_editor) if defined?(@permission_editor)
    rescue StandardError => e
      @client.logger.info("Permission #{@permission_editor} already deleted or doesn't exist: #{e.message}")
    end
    
    begin
      @client.delete_permission(@permission_admin) if defined?(@permission_admin)
    rescue StandardError => e
      @client.logger.info("Permission #{@permission_admin} already deleted or doesn't exist: #{e.message}")
    end
    
    # Delete any roles with our test description
    begin
      @client.load_all_roles['roles'].each do |role|
        if role['description'] == @description
          @client.delete_role(name: role['name'], tenant_id: role['tenantId'])
        end
      end
    rescue StandardError => e
      @client.logger.info("Error cleaning up roles: #{e.message}")
    end
    
    # Delete tenant
    begin
      @client.search_all_tenants(names: [@tenant_name])['tenants'].each do |tenant|
        @client.delete_tenant(tenant['id'])
      end
    rescue StandardError => e
      @client.logger.info("Error cleaning up tenant: #{e.message}")
    end
    
    @client.logger.info('Cleanup completed.')
  end

  it 'should create update and delete a role' do
    @client.logger.info('Testing role creation, update, deletion and search...')

    # Create permissions
    @client.logger.info('creating viewer permission for role')
    @client.create_permission(name: @permission_viewer, description: @description)

    @client.logger.info('creating editor permission for role')
    @client.create_permission(name: @permission_editor, description: @description)

    @client.logger.info('creating admin permission for role')
    @client.create_permission(name: @permission_admin, description: @description)

    # Create tenants
    @client.logger.info("creating #{@tenant_name} tenant")
    tenant_id = @client.create_tenant(name: @tenant_name)['id']
    @client.logger.info("Created tenant with id: #{tenant_id}")
    
    # Wait for tenant to be available (polling, up to 5 seconds)
    timeout = 5.0
    interval = 0.1
    waited = 0.0
    loop do
      tenants = @client.search_all_tenants(names: [@tenant_name])['tenants']
      break if tenants.any? { |t| t['id'] == tenant_id }
      raise "Tenant #{@tenant_name} not available after #{timeout} seconds" if waited >= timeout
      sleep(interval)
      waited += interval
    end

    # Create roles
    @client.logger.info("creating #{@role_viewer} role")
    @client.create_role(name: @role_viewer, description: @description, permission_names: [@permission_viewer])
    @client.logger.info("creating #{@role_admin} role")
    @client.create_role(name: @role_admin, description: @description, permission_names: [@permission_admin], tenant_id:)

    # check all roles matching the correct permission
    @client.logger.info('check all roles matching the correct permission (load roles)')
    roles = @client.load_all_roles['roles']
    roles.each do |role|
      expect(role['permissionNames']).to include(@permission_viewer) if role['name'] == @role_viewer
      expect(role['permissionNames']).to include(@permission_admin) if role['name'] == @role_admin
    end

    @client.logger.info('updating role')
    @client.update_role(
      name: @role_viewer,
      new_name: @role_editor,
      description: @description,
      permission_names: [@permission_editor]
    )

    @client.logger.info('searching for roles by role names...')
    all_roles = @client.search_roles(role_names: [@role_admin, @role_editor])['roles']
    expected_roles = [@role_editor, @role_admin]
    role_count = 0
    expected_roles.each do |expected_role|
      expect(all_roles.map { |role| role['name'] }).to include(expected_role)
      role_count += 1
    end
    expect(role_count).to eq(2)

    @client.logger.info('searching for roles with role name like...')
    all_roles = @client.search_roles(role_name_like: "#{@test_prefix}Ruby-SDK-test")['roles']
    expected_roles = [@role_editor, @role_admin]
    role_count = 0
    expected_roles.each do |expected_role|
      expect(all_roles.map { |role| role['name'] }).to include(expected_role)
      role_count += 1
    end

    expect(role_count).to eq(2)

    @client.logger.info('searching for roles with permission names...')
    all_roles = @client.search_roles(permission_names: [@permission_admin])['roles']
    expect(all_roles.map { |role| role['name'] }).to include(@role_admin)

    @client.logger.info('searching for roles with tenant ids...')
    all_roles = @client.search_roles(role_name_like: "#{@test_prefix}Ruby-SDK-test", tenant_ids: [tenant_id])['roles']
    expect(all_roles.map { |role| role['name'] }).to include(@role_admin)

    @client.logger.info('deleting permission')

    @client.delete_permission(@permission_editor)
    @client.delete_permission(@permission_admin)

    @client.logger.info('deleting editor role')
    @client.delete_role(name: @role_editor)

    @client.logger.info('deleting admin role')
    begin
      @client.delete_role(name: @role_admin, tenant_id:)
    rescue Descope::Unauthorized, Descope::NotFound => e
      @client.logger.info("Admin role already deleted or tenant invalid: #{e.message}")
    end

    @client.logger.info('deleting tenant')
    begin
      @client.delete_tenant(tenant_id)
    rescue Descope::NotFound => e
      @client.logger.info("Tenant already deleted: #{e.message}")
    end
  end
end
