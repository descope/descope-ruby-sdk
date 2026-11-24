# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::SSOSettings do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::SSOSettings)
    @instance = dummy_instance
  end

  context '.get_sso_settings' do
    it 'should respond to .get_sso_settings' do
      expect(@instance).to respond_to :get_sso_settings
    end

    it 'is expected to get SSO settings' do
      expect(@instance).to receive(:mgmt_get).with(
        SSO_SETTINGS_PATH, { tenantId: '123' }
      )
      expect { @instance.get_sso_settings('123') }.not_to raise_error
    end
  end

  context '.delete_sso_settings' do
    it 'should respond to .delete_sso_settings' do
      expect(@instance).to respond_to :delete_sso_settings
    end

    it 'is expected to delete SSO settings' do
      expect(@instance).to receive(:mgmt_delete).with(
        SSO_SETTINGS_PATH, { tenantId: '123' }
      )
      expect { @instance.delete_sso_settings('123') }.not_to raise_error
    end

    context '.configure_sso_oidc_settings' do
      it 'should respond to .configure_sso_oidc' do
        expect(@instance).to respond_to :configure_sso_oidc
      end

      it 'is expected to configure SSO settings' do
        expect(@instance).to receive(:mgmt_post).with(
          SSO_OIDC_PATH, {
            tenantId: '123',
            settings: {
              name: 'test',
              clientId: 'test',
              scope: ['test'],
              userAttrMapping: {
                loginId: 'test',
                username: 'test',
                name: 'test'
              },
              callbackDomain: 'test'
            },
            redirectUrl: 'test',
            domain: 'test'
          }
        )
        expect do
          @instance.configure_sso_oidc(
            tenant_id: '123',
            settings: {
              name: 'test',
              client_id: 'test',
              scope: ['test'],
              user_attr_mapping: {
                login_id: 'test',
                username: 'test',
                name: 'test'
              },
              callback_domain: 'test'
            },
            redirect_url: 'test',
            domain: 'test'
          )
        end.not_to raise_error
      end
    end
  end

  context '.configure_sso_saml_settings' do
    let(:attribute_mapping) do
      {
        name: 'displayName',
        email: 'mail',
        phone_number: 'phone',
        group: 'groups',
        given_name: 'firstName',
        family_name: 'lastName',
        custom_attributes: { 'department' => 'dept' }
      }
    end
    let(:expected_attribute_mapping) do
      {
        name: 'displayName',
        email: 'mail',
        phoneNumber: 'phone',
        group: 'groups',
        givenName: 'firstName',
        familyName: 'lastName',
        customAttributes: { 'department' => 'dept' }
      }
    end
    let(:required_settings) do
      { idp_url: 'https://idp.example.com/sso', idp_entity_id: 'idp-entity', idp_cert: 'cert' }
    end
    let(:required_settings_body) do
      { idpUrl: 'https://idp.example.com/sso', entityId: 'idp-entity', idpCert: 'cert' }
    end

    it 'should respond to .configure_sso_saml' do
      expect(@instance).to respond_to :configure_sso_saml
    end

    it 'raises when settings is not a Hash' do
      expect { @instance.configure_sso_saml(tenant_id: '123') }.to raise_error(Descope::ArgumentException)
    end

    it 'posts the SAML settings to the SAML endpoint' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_SETTINGS_PATH, {
          tenantId: '123',
          settings: {
            idpUrl: 'https://idp.example.com/sso',
            entityId: 'idp-entity',
            idpCert: 'cert',
            idpAdditionalCerts: ['cert2'],
            defaultSSORoles: ['viewer'],
            groupsPriority: %w[admins users],
            configFGATenantIDResourcePrefix: 'pre',
            configFGATenantIDResourceSuffix: 'suf',
            disableSignRequest: true,
            authenticationOnly: false,
            jitDisabled: true,
            spACSUrl: 'https://sp.example.com/acs',
            spEntityId: 'sp-entity',
            attributeMapping: expected_attribute_mapping,
            roleMappings: [{ groups: %w[admins], roleName: 'Tenant Admin' }],
            fgaMappings: {
              'admins' => { relations: [{ resource: 'doc1', relationDefinition: 'owner', namespace: 'doc' }] }
            }
          },
          redirectUrl: 'https://app.example.com',
          domains: ['example.com']
        }
      )
      @instance.configure_sso_saml(
        tenant_id: '123',
        settings: required_settings.merge(
          idp_additional_certs: ['cert2'],
          attribute_mapping:,
          role_mappings: [{ groups: %w[admins], role_name: 'Tenant Admin' }],
          default_sso_roles: ['viewer'],
          groups_priority: %w[admins users],
          fga_mappings: {
            'admins' => { relations: [{ resource: 'doc1', relation_definition: 'owner', namespace: 'doc' }] }
          },
          config_fga_tenant_id_resource_prefix: 'pre',
          config_fga_tenant_id_resource_suffix: 'suf',
          disable_sign_request: true,
          authentication_only: false,
          jit_disabled: true,
          sp_acs_url: 'https://sp.example.com/acs',
          sp_entity_id: 'sp-entity'
        ),
        redirect_url: 'https://app.example.com',
        domain: 'example.com'
      )
    end

    it 'sends domain and domains together' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_SETTINGS_PATH, {
          tenantId: '123', settings: required_settings_body, redirectUrl: nil,
          domains: ['a.example.com', 'b.example.com']
        }
      )
      @instance.configure_sso_saml(
        tenant_id: '123', settings: required_settings, domains: ['a.example.com'], domain: 'b.example.com'
      )
    end

    it 'sends the replace flag when default_sso_roles is an empty array' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_SETTINGS_PATH, {
          tenantId: '123',
          settings: required_settings_body.merge(defaultSSORoles: [], replaceDefaultSSORoles: true),
          redirectUrl: nil,
          domains: []
        }
      )
      @instance.configure_sso_saml(tenant_id: '123', settings: required_settings.merge(default_sso_roles: []))
    end

    it 'does not send accepted audiences when accepted_audiences is nil' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_SETTINGS_PATH,
        { tenantId: '123', settings: required_settings_body, redirectUrl: nil, domains: [] }
      )
      @instance.configure_sso_saml(tenant_id: '123', settings: required_settings, accepted_audiences: nil)
    end

    it 'replaces accepted audiences when accepted_audiences is a list' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_SETTINGS_PATH, {
          tenantId: '123',
          settings: required_settings_body.merge(
            acceptedAudiences: ['https://idp.example.com/aud', ''],
            replaceAcceptedAudiences: true
          ),
          redirectUrl: nil,
          domains: []
        }
      )
      @instance.configure_sso_saml(
        tenant_id: '123',
        settings: required_settings,
        accepted_audiences: ['https://idp.example.com/aud', '']
      )
    end

    it 'clears accepted audiences when accepted_audiences is an empty array' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_SETTINGS_PATH, {
          tenantId: '123',
          settings: required_settings_body.merge(acceptedAudiences: [], replaceAcceptedAudiences: true),
          redirectUrl: nil,
          domains: []
        }
      )
      @instance.configure_sso_saml(tenant_id: '123', settings: required_settings, accepted_audiences: [])
    end
  end

  context '.configure_sso_saml_metadata' do
    let(:metadata_settings) { { idp_metadata_url: 'https://idp.example.com/metadata' } }
    let(:metadata_settings_body) { { idpMetadataUrl: 'https://idp.example.com/metadata' } }

    it 'should respond to .configure_sso_saml_metadata' do
      expect(@instance).to respond_to :configure_sso_saml_metadata
    end

    it 'raises when settings is not a Hash' do
      expect { @instance.configure_sso_saml_metadata(tenant_id: '123') }.to raise_error(Descope::ArgumentException)
    end

    it 'posts the SAML settings to the SAML metadata endpoint' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_METADATA_PATH, {
          tenantId: '123',
          settings: {
            idpMetadataUrl: 'https://idp.example.com/metadata',
            entityId: 'idp-entity',
            defaultSSORoles: ['viewer'],
            groupsPriority: %w[admins],
            disableSignRequest: false,
            spACSUrl: 'https://sp.example.com/acs',
            spEntityId: 'sp-entity',
            attributeMapping: { name: 'displayName', email: 'mail', group: 'groups' },
            roleMappings: [{ groups: %w[admins], roleName: 'Tenant Admin' }]
          },
          redirectUrl: 'https://app.example.com',
          domains: ['example.com']
        }
      )
      @instance.configure_sso_saml_metadata(
        tenant_id: '123',
        settings: metadata_settings.merge(
          idp_entity_id: 'idp-entity',
          attribute_mapping: { name: 'displayName', email: 'mail', group: 'groups' },
          role_mappings: [{ groups: %w[admins], role_name: 'Tenant Admin' }],
          default_sso_roles: ['viewer'],
          groups_priority: %w[admins],
          disable_sign_request: false,
          sp_acs_url: 'https://sp.example.com/acs',
          sp_entity_id: 'sp-entity',
          idp_url: 'ignored for metadata',
          idp_cert: 'ignored for metadata'
        ),
        redirect_url: 'https://app.example.com',
        domain: 'example.com'
      )
    end

    it 'does not send accepted audiences when accepted_audiences is nil' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_METADATA_PATH,
        { tenantId: '123', settings: metadata_settings_body, redirectUrl: nil, domains: [] }
      )
      @instance.configure_sso_saml_metadata(tenant_id: '123', settings: metadata_settings, accepted_audiences: nil)
    end

    it 'replaces accepted audiences when accepted_audiences is a list' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_METADATA_PATH, {
          tenantId: '123',
          settings: metadata_settings_body.merge(
            acceptedAudiences: ['https://idp.example.com/aud', ''],
            replaceAcceptedAudiences: true
          ),
          redirectUrl: nil,
          domains: []
        }
      )
      @instance.configure_sso_saml_metadata(
        tenant_id: '123',
        settings: metadata_settings,
        accepted_audiences: ['https://idp.example.com/aud', '']
      )
    end

    it 'clears accepted audiences when accepted_audiences is an empty array' do
      expect(@instance).to receive(:mgmt_post).with(
        SSO_CONFIGURE_SAML_METADATA_PATH, {
          tenantId: '123',
          settings: metadata_settings_body.merge(acceptedAudiences: [], replaceAcceptedAudiences: true),
          redirectUrl: nil,
          domains: []
        }
      )
      @instance.configure_sso_saml_metadata(tenant_id: '123', settings: metadata_settings, accepted_audiences: [])
    end
  end
end
