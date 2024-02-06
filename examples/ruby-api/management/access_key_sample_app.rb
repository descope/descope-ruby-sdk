#!/usr/bin/env ruby

require 'descope'

project_id = ENV['DESCOPE_PROJECT_ID']
management_key = ENV['DESCOPE_MANAGEMENT_KEY']

begin
  client = Descope::Client.new({ project_id:, management_key: })
  key_id = ""

  puts "Going to create a new access key"
  res = client.create_access_key(name: 'key-name', expire_time: (Time.now + 10 * 60).to_i)
  access_key = res['key']
  key_id = access_key['id']
  puts "Created access key: #{access_key}"
rescue Descope::AuthException => e
  puts "AccessKey creation failed: #{e}"
end
