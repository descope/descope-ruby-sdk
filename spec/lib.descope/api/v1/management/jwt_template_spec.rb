# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::JWTTemplate do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::JWTTemplate)
    @instance = dummy_instance
  end

  context '.create_jwt_template' do
    it 'should respond to .create_jwt_template' do
      expect(@instance).to respond_to :create_jwt_template
    end

    it 'is expected to create a new JWT template' do
      template = {
        name: 'name-of-template',
        description: 'description of the template',
        template: 'the template body',
        conformanceIssuer: true,
        authSchema: 'default'
      }
      expect(@instance).to receive(:post).with(
        JWT_TEMPLATE_CREATE_PATH,
        { template: template }
      )
      expect do
        @instance.create_jwt_template(template: template)
      end.not_to raise_error
    end
  end

  context '.update_jwt_template' do
    it 'should respond to .update_jwt_template' do
      expect(@instance).to respond_to :update_jwt_template
    end

    it 'is expected to update an existing JWT template' do
      template = {
        id: 'template-id',
        name: 'name-of-template',
        template: 'the template body'
      }
      expect(@instance).to receive(:post).with(
        JWT_TEMPLATE_UPDATE_PATH,
        { template: template }
      )
      expect do
        @instance.update_jwt_template(template: template)
      end.not_to raise_error
    end
  end

  context '.delete_jwt_template' do
    it 'should respond to .delete_jwt_template' do
      expect(@instance).to respond_to :delete_jwt_template
    end

    it 'is expected to delete the given JWT template' do
      expect(@instance).to receive(:post).with(
        JWT_TEMPLATE_DELETE_PATH,
        { id: 'template-id' }
      )
      expect do
        @instance.delete_jwt_template(id: 'template-id')
      end.not_to raise_error
    end
  end

  context '.list_jwt_templates' do
    it 'should respond to .list_jwt_templates' do
      expect(@instance).to respond_to :list_jwt_templates
    end

    it 'is expected to list all JWT templates' do
      expect(@instance).to receive(:post).with(
        JWT_TEMPLATE_LIST_PATH,
        {}
      )
      expect do
        @instance.list_jwt_templates
      end.not_to raise_error
    end
  end

  context '.load_jwt_template' do
    it 'should respond to .load_jwt_template' do
      expect(@instance).to respond_to :load_jwt_template
    end

    it 'is expected to load the given JWT template' do
      expect(@instance).to receive(:post).with(
        JWT_TEMPLATE_LOAD_PATH,
        { id: 'template-id' }
      )
      expect do
        @instance.load_jwt_template(id: 'template-id')
      end.not_to raise_error
    end
  end
end
