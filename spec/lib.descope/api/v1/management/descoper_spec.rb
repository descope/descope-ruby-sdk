# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Descoper do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Descoper)
    @instance = dummy_instance
  end

  context '.create_descoper' do
    it 'should respond to .create_descoper' do
      expect(@instance).to respond_to :create_descoper
    end

    it 'is expected to create the given descopers' do
      expect(@instance).to receive(:put).with(
        DESCOPER_CREATE_PATH,
        {
          descopers: [{ name: 'test-descoper' }]
        }
      )
      expect do
        @instance.create_descoper([{ name: 'test-descoper' }])
      end.not_to raise_error
    end
  end

  context '.update_descoper' do
    it 'should respond to .update_descoper' do
      expect(@instance).to respond_to :update_descoper
    end

    it 'is expected to update the given descoper' do
      expect(@instance).to receive(:patch).with(
        DESCOPER_UPDATE_PATH,
        {
          id: 'test-id',
          attributes: { key: 'value' },
          rbac: { roles: ['admin'] }
        }
      )
      expect do
        @instance.update_descoper(id: 'test-id', attributes: { key: 'value' }, rbac: { roles: ['admin'] })
      end.not_to raise_error
    end
  end

  context '.get_descoper' do
    it 'should respond to .get_descoper' do
      expect(@instance).to respond_to :get_descoper
    end

    it 'is expected to get the given descoper by id' do
      expect(@instance).to receive(:get).with(
        DESCOPER_GET_PATH,
        {
          id: 'test-id'
        }
      )
      expect do
        @instance.get_descoper(id: 'test-id')
      end.not_to raise_error
    end
  end

  context '.delete_descoper' do
    it 'should respond to .delete_descoper' do
      expect(@instance).to respond_to :delete_descoper
    end

    it 'is expected to delete the given descoper by id' do
      expect(@instance).to receive(:delete).with(
        DESCOPER_DELETE_PATH,
        {
          id: 'test-id'
        }
      )
      expect do
        @instance.delete_descoper(id: 'test-id')
      end.not_to raise_error
    end
  end

  context '.search_descopers' do
    it 'should respond to .search_descopers' do
      expect(@instance).to respond_to :search_descopers
    end

    it 'is expected to search (list) all descopers' do
      expect(@instance).to receive(:post).with(
        DESCOPER_SEARCH_PATH,
        {}
      )
      expect do
        @instance.search_descopers
      end.not_to raise_error
    end
  end
end
