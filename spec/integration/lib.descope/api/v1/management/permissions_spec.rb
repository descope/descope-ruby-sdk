# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Permission do
  before(:all) do
    raise 'DESCOPE_MANAGEMENT_KEY is not set' if ENV['DESCOPE_MANAGEMENT_KEY'].nil?

    @client = DescopeClient.new(Configuration.config)
    @client.load_all_permissions['permissions'].each do |perm|
      if perm['description'] == "#{SpecUtils.build_prefix} Ruby SDK"
        puts "Deleting permission: #{perm['name']}"
        @client.delete_permission(perm['name'])
      end
    end
  end

  it 'should create update and delete a permission' do
    @client.create_permission(name: 'test_permission', description: "#{SpecUtils.build_prefix} Ruby SDK")
    all_permissions = @client.load_all_permissions['permissions']
    expect(all_permissions.any? { |perm| perm['name'] == 'test_permission' }).to eq(true)
    @client.update_permission(name: 'test_permission', new_name: 'test_permission_2')
    all_permissions = @client.load_all_permissions['permissions']
    expect(all_permissions.any? { |perm| perm['name'] == 'test_permission_2' }).to eq(true)
    @client.delete_permission('test_permission_2')
    all_permissions = @client.load_all_permissions['permissions']
    expect(all_permissions.any? { |perm| perm['name'] == 'test_permission_2' }).to eq(false)
  end
end
