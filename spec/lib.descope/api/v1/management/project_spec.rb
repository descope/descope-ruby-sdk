# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Project do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Project)
    @instance = dummy_instance
  end

  context '.rename_project' do
    it 'should respond to .rename_project' do
      expect(@instance).to respond_to :rename_project
    end

    it 'is expected to rename the current project' do
      expect(@instance).to receive(:post).with(
        PROJECT_UPDATE_NAME, { name: 'test' }
      )
      expect { @instance.rename_project('test') }.not_to raise_error
    end
  end

  context '.export_project' do
    it 'should respond to .export_project' do
      expect(@instance).to respond_to :export_project
    end

    it 'is expected to export the current project' do
      expect(@instance).to receive(:post).with(
        PROJECT_EXPORT_PATH, { format: 'string' }
      )
      expect do
        res = @instance.export_project('string')
        JSON.parse(res)
      end.not_to raise_error
    end
  end

  context '.import_project' do
    it 'should respond to .import_project' do
      expect(@instance).to respond_to :import_project
    end

    it 'is expected to import a project' do
      expect(@instance).to receive(:post).with(
        PROJECT_IMPORT_PATH, { files: 'files' }
      )
      expect do
        @instance.import_project('files')
      end.not_to raise_error
    end
  end

  context '.clone_project' do
    it 'should respond to .clone_project' do
      expect(@instance).to respond_to :clone_project
    end

    it 'is expected to clone the current project' do
      expect(@instance).to receive(:post).with(PROJECT_CLONE, { name: 'test', tag: 'test' })
      expect { @instance.clone_project(name: 'test', tag: 'test') }.not_to raise_error
    end
  end
end
