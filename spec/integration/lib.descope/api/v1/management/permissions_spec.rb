# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Permission do
  before(:all) do
    raise 'DESCOPE_MANAGEMENT_KEY is not set' if ENV['DESCOPE_MANAGEMENT_KEY'].nil?

    @client = DescopeClient.new(Configuration.config)
    @test_description = "#{SpecUtils.build_prefix} Ruby SDK"
    
    # Cleanup any leftover permissions from previous failed runs
    @client.load_all_permissions['permissions'].each do |perm|
      if perm['description'] == @test_description
        puts "Deleting permission: #{perm['name']}"
        @client.delete_permission(perm['name'])
      end
    end
  end
  
  after(:all) do
    # Safety cleanup to ensure no test permissions are left behind
    @client.logger.info('Cleaning up test permissions...')
    begin
      @client.load_all_permissions['permissions'].each do |perm|
        if perm['description'] == @test_description
          @client.logger.info("Deleting leftover permission: #{perm['name']}")
          @client.delete_permission(perm['name'])
        end
      end
    rescue StandardError => e
      @client.logger.info("Error during permission cleanup: #{e.message}")
    end
  end

  it 'should create update and delete a permission' do
    @client.create_permission(name: 'test_permission', description: @test_description)
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
