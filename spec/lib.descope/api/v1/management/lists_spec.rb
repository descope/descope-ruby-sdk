# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Lists do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Lists)
    @instance = dummy_instance
  end

  context '.create_list' do
    it 'should respond to .create_list' do
      expect(@instance).to respond_to :create_list
    end

    it 'is expected to create a new list' do
      expect(@instance).to receive(:post).with(
        LIST_CREATE_PATH,
        {
          name: 'test-list',
          type: 'ip',
          description: 'test description',
          data: { 'foo' => 'bar' }
        }
      )
      expect do
        @instance.create_list(
          name: 'test-list',
          type: 'ip',
          description: 'test description',
          data: { 'foo' => 'bar' }
        )
      end.not_to raise_error
    end

    it 'is expected to create a new list without optional fields' do
      expect(@instance).to receive(:post).with(
        LIST_CREATE_PATH,
        { name: 'test-list', type: 'ip' }
      )
      expect do
        @instance.create_list(name: 'test-list', type: 'ip')
      end.not_to raise_error
    end
  end

  context '.update_list' do
    it 'should respond to .update_list' do
      expect(@instance).to respond_to :update_list
    end

    it 'is expected to update an existing list' do
      expect(@instance).to receive(:post).with(
        LIST_UPDATE_PATH,
        {
          id: 'test-id',
          name: 'test-list',
          type: 'ip',
          description: 'test description',
          data: { 'foo' => 'bar' }
        }
      )
      expect do
        @instance.update_list(
          id: 'test-id',
          name: 'test-list',
          type: 'ip',
          description: 'test description',
          data: { 'foo' => 'bar' }
        )
      end.not_to raise_error
    end
  end

  context '.delete_list' do
    it 'should respond to .delete_list' do
      expect(@instance).to respond_to :delete_list
    end

    it 'is expected to delete an existing list' do
      expect(@instance).to receive(:post).with(
        LIST_DELETE_PATH,
        { id: 'test-id' }
      )
      expect do
        @instance.delete_list(id: 'test-id')
      end.not_to raise_error
    end
  end

  context '.load_list' do
    it 'should respond to .load_list' do
      expect(@instance).to respond_to :load_list
    end

    it 'is expected to load a list by id' do
      expect(@instance).to receive(:get).with("#{LIST_LOAD_PATH}/test-id")
      expect do
        @instance.load_list(id: 'test-id')
      end.not_to raise_error
    end
  end

  context '.load_list_by_name' do
    it 'should respond to .load_list_by_name' do
      expect(@instance).to respond_to :load_list_by_name
    end

    it 'is expected to load a list by name' do
      expect(@instance).to receive(:get).with("#{LIST_LOAD_BY_NAME_PATH}/test-list")
      expect do
        @instance.load_list_by_name(name: 'test-list')
      end.not_to raise_error
    end
  end

  context '.load_all_lists' do
    it 'should respond to .load_all_lists' do
      expect(@instance).to respond_to :load_all_lists
    end

    it 'is expected to load all lists' do
      expect(@instance).to receive(:get).with(LIST_LOAD_ALL_PATH)
      expect do
        @instance.load_all_lists
      end.not_to raise_error
    end
  end

  context '.import_lists' do
    it 'should respond to .import_lists' do
      expect(@instance).to respond_to :import_lists
    end

    it 'is expected to import the given lists' do
      lists = [{ name: 'test-list', type: 'ip' }]
      expect(@instance).to receive(:post).with(
        LIST_IMPORT_PATH,
        { lists: }
      )
      expect do
        @instance.import_lists(lists:)
      end.not_to raise_error
    end
  end

  context '.list_add_ips' do
    it 'should respond to .list_add_ips' do
      expect(@instance).to respond_to :list_add_ips
    end

    it 'is expected to add the given IPs to the list' do
      expect(@instance).to receive(:post).with(
        LIST_ADD_IPS_PATH,
        { id: 'test-id', ips: ['1.2.3.4'] }
      )
      expect do
        @instance.list_add_ips(id: 'test-id', ips: ['1.2.3.4'])
      end.not_to raise_error
    end
  end

  context '.list_remove_ips' do
    it 'should respond to .list_remove_ips' do
      expect(@instance).to respond_to :list_remove_ips
    end

    it 'is expected to remove the given IPs from the list' do
      expect(@instance).to receive(:post).with(
        LIST_REMOVE_IPS_PATH,
        { id: 'test-id', ips: ['1.2.3.4'] }
      )
      expect do
        @instance.list_remove_ips(id: 'test-id', ips: ['1.2.3.4'])
      end.not_to raise_error
    end
  end

  context '.list_check_ip' do
    it 'should respond to .list_check_ip' do
      expect(@instance).to respond_to :list_check_ip
    end

    it 'is expected to check whether the given IP exists in the list' do
      expect(@instance).to receive(:post).with(
        LIST_CHECK_IP_PATH,
        { id: 'test-id', ip: '1.2.3.4' }
      )
      expect do
        @instance.list_check_ip(id: 'test-id', ip: '1.2.3.4')
      end.not_to raise_error
    end
  end

  context '.list_add_texts' do
    it 'should respond to .list_add_texts' do
      expect(@instance).to respond_to :list_add_texts
    end

    it 'is expected to add the given texts to the list' do
      expect(@instance).to receive(:post).with(
        LIST_ADD_TEXTS_PATH,
        { id: 'test-id', texts: ['some-text'] }
      )
      expect do
        @instance.list_add_texts(id: 'test-id', texts: ['some-text'])
      end.not_to raise_error
    end
  end

  context '.list_remove_texts' do
    it 'should respond to .list_remove_texts' do
      expect(@instance).to respond_to :list_remove_texts
    end

    it 'is expected to remove the given texts from the list' do
      expect(@instance).to receive(:post).with(
        LIST_REMOVE_TEXTS_PATH,
        { id: 'test-id', texts: ['some-text'] }
      )
      expect do
        @instance.list_remove_texts(id: 'test-id', texts: ['some-text'])
      end.not_to raise_error
    end
  end

  context '.list_check_text' do
    it 'should respond to .list_check_text' do
      expect(@instance).to respond_to :list_check_text
    end

    it 'is expected to check whether the given text exists in the list' do
      expect(@instance).to receive(:post).with(
        LIST_CHECK_TEXT_PATH,
        { id: 'test-id', text: 'some-text' }
      )
      expect do
        @instance.list_check_text(id: 'test-id', text: 'some-text')
      end.not_to raise_error
    end
  end

  context '.clear_list' do
    it 'should respond to .clear_list' do
      expect(@instance).to respond_to :clear_list
    end

    it 'is expected to clear all entries from the list' do
      expect(@instance).to receive(:post).with(
        LIST_CLEAR_PATH,
        { id: 'test-id' }
      )
      expect do
        @instance.clear_list(id: 'test-id')
      end.not_to raise_error
    end
  end
end
