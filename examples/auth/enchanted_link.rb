# frozen_string_literal: true

require 'descope'

client = Descope::Client.new(
  {
    project_id: 'P2P3hlbsUIyy5H65B56jEE9oXZXD',
    descope_api_url: 'https://app.descope.org',
    management_key: ENV['MGMT_KEY']
  }
)

# URI = 'https://app.descope.com'

# Sign up or sign in
#res = client.enchanted_link_sign_up_or_in(login_id: 'ami+1@descope.com')
res = client.load_user(login_id: 'ami+1@descope.com')
puts "exmple response: #{res}"
