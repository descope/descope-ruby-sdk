# frozen_string_literal: true

require 'descope'

dev_project_id = 'P2ZoKhzAdvZV9HzRZ0SE8pIdNq8P'
client = Descope::Client.new(
  {
    project_id: dev_project_id,
    management_key: ENV['MGMT_KEY']
  }
)

# Create user
def create_test_user(client, tenant_id, role_names)
  user_create_res = client.create_test_user(
    login_id: 'ami_ruby_sdk+6ami@descope.com',
    #email: 'ami_ruby_sdk+5ami@descope.com',
    #phone: '+1-347-450-0361',
    display_name: 'Ami Ruby SDK',
    user_tenants: [
      {
        tenant_id: tenant_id,
        role_names: role_names
      }
    ],
    picture: 'https://static-00.iconduck.com/assets.00/ruby-gems-icon-447x512-6feckqly.png',
    family_name: 'Ruby',
    given_name: 'SDK'
  )

  puts "user_create_res: #{user_create_res}"
  user_create_res
end

def update_user(client, login_id)
  user_create_res = client.update_user(
    login_id: login_id,
    email: 'just_updated+ami@descope.com',
    phone: '+1-972-450-0361',
    display_name: 'UPDATED Ruby SDK',
    family_name: 'UPDATED Ruby',
    given_name: 'UPDATED SDK'
  )

  puts "user_create_res: #{user_create_res}"
  user_create_res
end

def load_user(client, login_id)
  user_load_res = client.load_user(login_id: login_id)
  puts "user_load_res: #{user_load_res}"
  user_load_res
end

def load_user_by_id(client, user_id)
  user_load_res = client.load_by_user_id(user_id: user_id)
  puts "user_load_res: #{user_load_res}"
  user_load_res
end

def enchanted(client, login_id)
  user_load_res = client.enchanted_link_sign_in(login_id: login_id)
  puts "user_load_res: #{user_load_res}"
  user_load_res
end

tenanat_id = 'T2Zp93ZrKlLl1SQDxzO0LTU8i4qU'
role_names = ['RubySdkAdmin']
# res = create_test_user(client, tenanat_id, role_names)
#load_user(client, 'stam@nowhere.com')
# update_user_res = update_user(client, 'ami_ruby_sdk+6ami@descope.com')
# client.delete_user(login_id: 'ami_ruby_sdk+6ami@descope.com')
# client.delete_all_test_users()

res = client.sign_in(login_id: 'ami+1@descope.com', password: 'Fl@ffybunny123')
puts "exmple response: #{res}"