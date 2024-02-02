# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Project do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
    @export_output = @client.export_project
  end

  context 'Project ops' do
    after(:all) do
      @client.rename_project('Ruby-SDK-Prod')
    end

    it 'should rename a project' do
      @client.rename_project('TEST-Ruby-SDK-Prod')
    end

    it 'should export a project' do
      expect(@export_output).to_not be_empty
      expect(@export_output).to be_a(Hash)
    end

    it 'should import a project' do
      @client.import_project(files: @export_output['files'])
    end

    it 'should clone a project and then delete it' do
      puts 'cloning the project...'
      cloned_project = @client.clone_project(name: 'Ami-Ruby-SDK-Production-Test-Clone', tag: 'production')
      expect(cloned_project['projectId']).to_not be_nil
      local_config = Configuration.config.dup
      local_config[:project_id] = cloned_project['projectId']
      puts "Local config: #{local_config}"
      clone_client = DescopeClient.new(local_config)
      puts "deleting cloned project #{cloned_project['projectId']}..."
      clone_client.delete_project
    end
  end
end
