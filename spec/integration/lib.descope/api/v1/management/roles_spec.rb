# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Role do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
    @client.load_all_permissions['permissions'].each do |perm|
      if perm['description'] == 'Ruby SDK'
        puts "Deleting permission: #{perm['name']}"
        @client.delete_permission(perm['name'])
      end
    end

    @client.load_all_roles['roles'].each do |role|
      if role['description'] == 'Ruby SDK'
        puts "Deleting role: #{role['name']}"
        @client.delete_role(role['name'])
      end
    end
  end

  it 'should create update and delete a role' do
    puts 'creating permission for role'
    @client.create_permission(name: 'test_permission', description: 'Ruby SDK')
    puts 'creating role'
    @client.create_role(name: 'Ruby SDK test role', description: 'Ruby SDK', permission_names: ['test_permission'])
    puts 'loading all roles'
    all_roles = @client.load_all_roles['roles']
    expect(all_roles.any? { |role| role['name'] == 'Ruby SDK test role' }).to eq(true)
    expect(all_roles.any? { |role| role['permissionNames'] == ['test_permission'] }).to eq(true)
    puts 'updating role'
    @client.update_role(name: 'Ruby SDK test role', new_name: 'Ruby SDK test role 2', description: 'Ruby SDK', permission_names: ['test_permission'])
    all_roles = @client.load_all_roles['roles']
    expect(all_roles.any? { |role| role['name'] == 'Ruby SDK test role 2' }).to eq(true)
    puts 'deleting permission'
    @client.delete_permission('test_permission')
    puts 'deleting role'
    @client.delete_role('Ruby SDK test role 2')
  end
end
