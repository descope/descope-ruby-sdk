# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::User do
  before(:all) do
    @password = SpecUtils.generate_password
    @new_password = SpecUtils.generate_password
    @user = build(:user)
    @client = DescopeClient.new(Configuration.config)
    include Descope::Mixins::Common::DeliveryMethod
  end

  after(:all) do
    all_users = @client.search_all_users
    all_users['users'].each do |user|
      if user['middleName'] == 'Ruby SDK User'
        puts "Deleting ruby spec test user #{user['loginIds'][0]}"
        @client.delete_user(user['loginIds'][0])
      end
    end
  end

  it 'should create a user' do
    user = build(:user)
    created_user = @client.create_user(**user)['user']

    loaded_user = @client.load_user(created_user['loginIds'][0])['user']

    expect(loaded_user['loginIds']).to eq(created_user['loginIds'])
    expect(loaded_user['email']).to eq(created_user['email'])
    expect(loaded_user['phone']).to eq(created_user['phone'])
    expect(loaded_user['display_name']).to eq(created_user['display_name'])
    expect(loaded_user['given_name']).to eq(created_user['given_name'])
    expect(loaded_user['middle_name']).to eq(created_user['middle_name'])
    expect(loaded_user['family_name']).to eq(created_user['family_name'])
    expect(loaded_user['picture']).to eq(created_user['picture'])
  end

  it 'should create batch users' do
    users = FactoryBot.build_list(:user, 5)
    batch_res = @client.create_batch_users(users)
    created_users = batch_res['createdUsers']

    created_users.each do |user|
      expect(user['status']).to eq('invited')
    end

    expect(batch_res['failedUsers']).to eq([])
  end

  it 'should update a user' do
    user = build(:user)
    created_user = @client.create_user(**user)['user']
    updated_first_name = 'new name'
    updated_user = @client.update_user(**user, given_name: updated_first_name)['user']

    expect(updated_user['first_name']).to eq(created_user[updated_first_name])
  end

  it 'should patch a user' do
    user = build(:user)
    role_name = 'some-new-role'

    # ensure no roles exist with that name
    all_roles = @client.load_all_roles
    all_roles['roles'].each do |role|
      @client.delete_role(name: role['name']) if role['name'] == role_name
    end

    @client.create_role(name: role_name)
    @client.create_user(**user)['user']
    updated_first_name = 'new name'
    updated_given_name = 'new given name'
    update_phone_number = "+1#{Faker::Number.number(digits: 10)}"
    updated_role_names = [role_name]
    updated_middle_name = 'new middle name'
    updated_user = @client.patch_user(
      **user,
      name: updated_first_name,
      given_name: updated_given_name,
      phone: update_phone_number,
      role_names: updated_role_names,
      middle_name: updated_middle_name
    )['user']

    puts "updated_user #{updated_user}"

    expect(updated_user['name']).to eq(updated_first_name)
    expect(updated_user['givenName']).to eq(updated_given_name)
    expect(updated_user['phone']).to eq(update_phone_number)
    expect(updated_user['roleNames']).to eq(updated_role_names)
    expect(updated_user['middleName']).to eq(updated_middle_name)
  end

  it 'should delete a user' do
    user = build(:user)
    created_user = @client.create_user(**user)['user']
    loaded_user = @client.load_user(created_user['loginIds'][0])['user']
    expect(loaded_user['loginIds']).to eq(created_user['loginIds'])
    sleep 10

    @client.delete_user(created_user['loginIds'][0])
    begin
      @client.load_user(created_user['loginIds'][0])
    rescue Descope::NotFound => e
      expect(e.message).to match(/"errorCode":"E112102"/)
    end
  end

  it 'should search all users' do
    users = FactoryBot.build_list(:user, 5)
    @client.create_batch_users(users)
    all_users = @client.search_all_users
    sdk_users = all_users['users'].select { |user| user['middleName'] == 'Ruby SDK User' }
    expect(sdk_users.length).to be >= 5
  end

  it 'should create a test user' do
    @client.delete_all_test_users
    sleep 5
    user_args = build(:user)
    test_user = @client.create_test_user(**user_args)['user']
    test_users = @client.search_all_users(test_users_only: true)['users']
    expect(test_users.length).to be >= 1
    expect(test_users[0]['loginIds'][0]).to eq(test_user['loginIds'][0])
  end

  it 'should update user status' do
    user_args = build(:user)
    user = @client.create_user(**user_args)['user']
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['status']).to eq('invited')
    @client.activate(user['loginIds'][0])
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['status']).to eq('enabled')
    @client.deactivate(user['loginIds'][0])
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['status']).to eq('disabled')
  end

  it 'should update user email' do
    user_args = build(:user)
    user = @client.create_user(**user_args)['user']
    email = Faker::Internet.email
    @client.update_email(login_id: user['loginIds'][0], email:)
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    puts "loaded_user #{loaded_user}"
    expect(loaded_user['email']).to eq(email)
  end

  it 'should update user phone' do
    user_args = build(:user)
    user = @client.create_user(**user_args)['user']
    phone = "+1#{Faker::Number.number(digits: 10)}"
    @client.update_phone(login_id: user['loginIds'][0], phone:)
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['phone']).to eq(phone)
  end

  it 'should update user picture' do
    user_args = build(:user)
    user = @client.create_user(**user_args)['user']
    picture = Faker::Internet.url
    @client.update_picture(login_id: user['loginIds'][0], picture:)
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['picture']).to eq(picture)
  end

  it 'should update user custom attributes' do
    user_args = build(:user)
    user = @client.create_user(**user_args, custom_attributes: { newUser: false })['user']
    puts "user## #{user}"
    @client.update_custom_attribute(login_id: user['loginIds'][0], attribute_key: 'newUser', attribute_value: true)
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    puts "loaded_user #{loaded_user}"
    expect(loaded_user['customAttributes']).to eq({ 'newUser' => true })
  end

  it 'should update display name' do
    user_args = build(:user)
    user = @client.create_user(**user_args)['user']
    name = Faker::Name.name
    @client.update_display_name(login_id: user['loginIds'][0], name:)
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['name']).to eq(name)
  end

  it 'should update user JWT and custom claims' do
    user_args = build(:user)
    password = SpecUtils.generate_password
    custom_claims = { "custom-key1": 'custom-value1', "custom-key2": 'custom-value2' }
    user = @client.create_user(**user_args, password:)['user']
    jwt = @client.password_sign_in(login_id: user['loginIds'][0], password:)['refreshSessionToken']['jwt']
    jwt_res = @client.update_jwt(jwt:, custom_claims:)
    decoded_jwt = @client.validate_token(jwt_res['jwt'])

    # check if all keys and values from custom_claims are present in decoded_jwt
    claims_in_jwt = custom_claims.all? do |k, v|
      decoded_jwt[k.to_s] == v
    end

    expect(claims_in_jwt).to be true
  end

  it 'should expire user password' do
    user_args = build(:user)
    password = SpecUtils.generate_password
    user = @client.create_user(**user_args, password:)['user']
    @client.password_sign_in(login_id: user['loginIds'][0], password:)
    begin
      @client.expire_password(user['loginIds'][0])
      @client.password_sign_in(login_id: user['loginIds'][0], password:)
    rescue Descope::ServerError => e
      expect(e.message).to match(/"errorCode":"E062909"/)
    end
  end

  it 'should set user password' do
    user_args = build(:user)
    password = SpecUtils.generate_password
    user = @client.create_user(**user_args, password:)['user']
    @client.password_sign_in(login_id: user['loginIds'][0], password:)

    begin
      new_password = SpecUtils.generate_password
      @client.set_password(login_id: user['loginIds'][0], password: new_password)
      @client.password_sign_in(login_id: user['loginIds'][0], password:)
    rescue Descope::ServerError => e
      expect(e.message).to match(/"errorCode":"E062909"/)
    end
  end

  it 'should update create tenant, add to user, remove from user and delete tenant' do
    res = @client.search_all_tenants(names: ['some-new-tenant'])
    puts "res #{res}"
    res['tenants'].each do |tenant|
      puts "Deleting tenant #{tenant['id']}"
      @client.delete_tenant(tenant['id'])
    end
    tenant_id = @client.create_tenant(name: 'some-new-tenant')['id']
    user_args = build(:user)
    user = @client.create_user(**user_args)['user']
    @client.user_add_tenant(login_id: user['loginIds'][0], tenant_id:)
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['userTenants'][0]['tenantId']).to eq(tenant_id)
    @client.user_remove_tenant(login_id: user['loginIds'][0], tenant_id:)
    @client.delete_tenant(tenant_id)
  end

  it 'should add and remove role from user create and delete role' do
    role_name = 'some-new-role'

    # ensure no roles exist with that name
    all_roles = @client.load_all_roles
    all_roles['roles'].each do |role|
      @client.delete_role(name: role['name']) if role['name'] == role_name
    end

    @client.create_role(name: role_name)
    user_args = build(:user)
    user = @client.create_user(**user_args)['user']
    @client.user_add_roles(login_id: user['loginIds'][0], role_names: ['some-new-role'])
    loaded_user = @client.load_user(user['loginIds'][0])['user']
    expect(loaded_user['roleNames'][0]).to eq(role_name)
    @client.user_remove_roles(login_id: user['loginIds'][0], role_names: [role_name])
    @client.delete_role(name: role_name)
  end


  it 'should logout user of all sessions' do
    user_args = build(:user)
    password = SpecUtils.generate_password
    user = @client.create_user(**user_args, password:)['user']
    session_token = @client.password_sign_in(login_id: user['loginIds'][0], password:)['refreshSessionToken']['jwt']
    @client.logout_user(user['loginIds'][0])
    @client.validate_and_refresh_session(session_token:)
  end

  it 'should generate login methods for test user' do
    @client.delete_all_test_users
    user_args = build(:user)
    user = @client.create_test_user(**user_args)['user']
    login_info = @client.generate_otp_for_test_user(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user['loginIds'][0])
    expect(login_info['loginId']).to eq(user['loginIds'][0])
    expect(login_info['code']).to_not be_nil

    login_info = @client.generate_enchanted_link_for_test_user(login_id: user['loginIds'][0], uri: 'http://localhost:3001/verify')
    expect(login_info['loginId']).to eq(user['loginIds'][0])
    expect(login_info['link']).to start_with('http://localhost:3001/verify?t=')
    expect(login_info['pendingRef']).to_not be_nil

    login_info = @client.generate_magic_link_for_test_user(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: user['loginIds'][0], uri: 'http://localhost:3001/verify')
    expect(login_info['loginId']).to eq(user['loginIds'][0])
    expect(login_info['link']).to start_with('http://localhost:3001/verify?t=')
  end
end
