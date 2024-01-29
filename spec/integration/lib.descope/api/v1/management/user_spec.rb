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
    puts "user is #{user}"
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

  # it 'should create batch users' do
  #   users =
  #   batch_res = @client.create_batch_users(users)
  # end

end
