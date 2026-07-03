# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::ScopeClaimMapping do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::ScopeClaimMapping)
    @instance = dummy_instance
  end

  context '.get_scope_claim_mapping' do
    it 'should respond to .get_scope_claim_mapping' do
      expect(@instance).to respond_to :get_scope_claim_mapping
    end

    it 'is expected to get the project-wide OIDC scope-to-claim mappings' do
      expect(@instance).to receive(:post).with(SCOPE_CLAIM_MAPPING_GET_PATH)
      expect do
        @instance.get_scope_claim_mapping
      end.not_to raise_error
    end
  end

  context '.set_scope_claim_mapping' do
    it 'should respond to .set_scope_claim_mapping' do
      expect(@instance).to respond_to :set_scope_claim_mapping
    end

    it 'is expected to set the project-wide OIDC scope-to-claim mappings' do
      mappings = [
        {
          scope: 'name-of-scope',
          claims: %w[claim1 claim2]
        }
      ]
      expect(@instance).to receive(:post).with(
        SCOPE_CLAIM_MAPPING_SET_PATH,
        { mappings: mappings }
      )
      expect do
        @instance.set_scope_claim_mapping(mappings: mappings)
      end.not_to raise_error
    end
  end

  context '.delete_scope_claim_mapping' do
    it 'should respond to .delete_scope_claim_mapping' do
      expect(@instance).to respond_to :delete_scope_claim_mapping
    end

    it 'is expected to delete the project-wide OIDC scope-to-claim mappings' do
      expect(@instance).to receive(:post).with(SCOPE_CLAIM_MAPPING_DELETE_PATH)
      expect do
        @instance.delete_scope_claim_mapping
      end.not_to raise_error
    end
  end
end
