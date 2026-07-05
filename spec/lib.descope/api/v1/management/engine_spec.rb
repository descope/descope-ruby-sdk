# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Engine do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Engine)
    @instance = dummy_instance
  end

  context '.create_engine' do
    it 'should respond to .create_engine' do
      expect(@instance).to respond_to :create_engine
    end

    it 'is expected to create a new engine' do
      expect(@instance).to receive(:post).with(
        ENGINE_CREATE_PATH,
        {
          name: 'test-engine'
        }
      )
      expect do
        @instance.create_engine(name: 'test-engine')
      end.not_to raise_error
    end
  end

  context '.update_engine' do
    it 'should respond to .update_engine' do
      expect(@instance).to respond_to :update_engine
    end

    it 'is expected to update an existing engine' do
      expect(@instance).to receive(:post).with(
        ENGINE_UPDATE_PATH,
        {
          id: 'test-id',
          name: 'test-engine'
        }
      )
      expect do
        @instance.update_engine(id: 'test-id', name: 'test-engine')
      end.not_to raise_error
    end
  end

  context '.delete_engine' do
    it 'should respond to .delete_engine' do
      expect(@instance).to respond_to :delete_engine
    end

    it 'is expected to delete an existing engine' do
      expect(@instance).to receive(:post).with(
        ENGINE_DELETE_PATH,
        {
          id: 'test-id'
        }
      )
      expect do
        @instance.delete_engine(id: 'test-id')
      end.not_to raise_error
    end
  end

  context '.load_engine' do
    it 'should respond to .load_engine' do
      expect(@instance).to respond_to :load_engine
    end

    it 'is expected to load an engine by id' do
      expect(@instance).to receive(:get).with(
        ENGINE_LOAD_PATH,
        {
          id: 'test-id'
        }
      )
      expect do
        @instance.load_engine(id: 'test-id')
      end.not_to raise_error
    end
  end

  context '.load_all_engines' do
    it 'should respond to .load_all_engines' do
      expect(@instance).to respond_to :load_all_engines
    end

    it 'is expected to load all engines' do
      expect(@instance).to receive(:get).with(ENGINE_LOAD_ALL_PATH)
      expect do
        @instance.load_all_engines
      end.not_to raise_error
    end
  end

  context '.rotate_engine_secret' do
    it 'should respond to .rotate_engine_secret' do
      expect(@instance).to respond_to :rotate_engine_secret
    end

    it 'is expected to rotate the secret for an engine' do
      expect(@instance).to receive(:post).with(
        ENGINE_ROTATE_SECRET_PATH,
        {
          id: 'test-id'
        }
      )
      expect do
        @instance.rotate_engine_secret(id: 'test-id')
      end.not_to raise_error
    end
  end
end
