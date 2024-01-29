# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::User do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
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

  it 'should delete a user' do
    user = build(:user)
    created_user = @client.create_user(**user)['user']
    loaded_user = @client.load_user(created_user['loginIds'][0])['user']
    expect(loaded_user['loginIds']).to eq(created_user['loginIds'])
    sleep(10)

    @client.delete_user(created_user['loginIds'][0])
    begin
      @client.load_user(created_user['loginIds'][0])
    rescue Descope::NotFound => e
      expect(e.message).to match(/"errorMessage":"User not found"/)
    end
  end
end
