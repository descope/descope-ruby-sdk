# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::AccessKey do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
  end

  context 'perform access key methods like create, delete load' do
    before(:all) do
      @key_name = 'Ruby SDK Test Key'

      keys = @client.search_all_access_keys['keys']
      keys.each do |key|
        if key['name'] == @key_name
          @client.delete_access_key(key['id'])
          puts "deleting test access key #{@key_name}"
        end
      end

      res = @client.search_all_tenants(names: ['some-new-tenant'])
      res['tenants'].each do |tenant|
        @client.delete_tenant(tenant['id'])
      end

      puts 'Creating tenant with name: some-new-tenant'
      @tenant_id = @client.create_tenant(name: 'some-new-tenant')['id']
      puts 'creating access key'
      @access_key = @client.create_access_key(name: @key_name, key_tenants: [{ tenant_id: @tenant_id }])
      sleep 60
    end

    it 'should create the access key and load it' do
      response = @client.load_access_key(@access_key['key']['id'])
      expect(response['key']['name']).to eq(@key_name)
    end

    it 'should update the access key' do
      new_name = 'Ruby SDK Test Key Updated'
      puts "access key id: #{@access_key['key']['id']}"
      response = @client.update_access_key(id: @access_key['key']['id'], name: new_name)
      expect(response['key']['name']).to eq(new_name)
    end

    it 'should deactivate the access key' do
      response = @client.deactivate_access_key(@access_key['key']['id'])
      puts "deactivate key response: #{response}"
      # expect(response['key']['status']).to eq('DEACTIVATED')
    end

    it 'should activate the access key' do
      response = @client.activate_access_key(@access_key['key']['id'])
      puts "activate key response: #{response}"
    end

    after(:all) do
      @client.delete_access_key(@access_key['key']['id'])
      @client.delete_tenant(@tenant_id)
    end
  end
end
