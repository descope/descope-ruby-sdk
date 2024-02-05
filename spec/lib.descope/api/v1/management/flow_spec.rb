# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Flow do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Flow)
    @instance = dummy_instance
  end

  context '.list_or_search_flows' do
    it 'should respond to .list_or_search_flows' do
      expect(@instance).to respond_to :list_or_search_flows
    end

    it 'is expected to get flows' do
      expect(@instance).to receive(:post).with(FLOW_LIST_PATH, { ids: %w[123 456] })
      expect { @instance.list_or_search_flows(%w[123 456]) }.not_to raise_error
    end
  end

  context '.export_flow' do
    it 'should respond to .export_flow' do
      expect(@instance).to respond_to :export_flow
    end

    it 'is expected to export flow' do
      expect(@instance).to receive(:post).with(FLOW_EXPORT_PATH, { flowId: '123' })
      expect { @instance.export_flow('123') }.not_to raise_error
    end
  end

  context '.import_flow' do
    it 'should respond to .import_flow' do
      expect(@instance).to respond_to :import_flow
    end

    it 'is expected to import flow' do
      expect(@instance).to receive(:post).with(
        FLOW_IMPORT_PATH, {
          flowId: '123',
          flow: 'flow',
          screens: %w[sign_up sign_in]
        }
      )
      expect do
        @instance.import_flow(
          flow_id: '123',
          flow: 'flow',
          screens: %w[sign_up sign_in]
        )
      end.not_to raise_error
    end
  end

  context '.export_theme' do
    it 'should respond to .export_theme' do
      expect(@instance).to respond_to :export_theme
    end

    it 'is expected to export theme' do
      expect(@instance).to receive(:post).with(THEME_EXPORT_PATH)
      expect { @instance.export_theme }.not_to raise_error
    end
  end

  context '.import_theme' do
    it 'should respond to .import_theme' do
      expect(@instance).to respond_to :import_theme
    end

    it 'is expected to import theme' do
      expect(@instance).to receive(:post).with(THEME_IMPORT_PATH, { theme: 'theme123' })
      expect { @instance.import_theme('theme123') }.not_to raise_error
    end
  end
end
