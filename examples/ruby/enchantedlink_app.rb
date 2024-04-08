#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './version_check'
require 'descope'

@logger = Logger.new($stdout)

@project_id = ENV['DESCOPE_PROJECT_ID']
@management_key = ENV['DESCOPE_MANAGEMENT_KEY']

@logger.info("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

@client = Descope::Client.new({ project_id: @project_id, management_key: @management_key })

def verify
  print "Please insert the token you received by email:\n"
  token = gets.chomp
  @client.enchanted_link_verify_token(token)
  p 'Token is valid'
rescue Descope::AuthException => e
  p "Invalid Token #{e}"
  raise
end

print 'Going to signup / signin using Enchanted Link ...'
print "Please insert email to signup / signin:\n"
email = gets.chomp
resp = @client.enchanted_link_sign_up_or_in(
  login_id: email,
  uri: 'http://test.me'
)

link_identifier = resp['linkId']
masked_email = resp['maskedEmail']
p "We have sent you an email to #{masked_email}"
p "Please click the link with the identifier #{link_identifier}"
pending_ref = resp['pendingRef']

done = false

# open thread to get input
thread = Thread.new { verify }
thread.join

i = 0
until done
  begin
    i += 1
    $stdout.write("Sleeping #{i}...")
    sleep(4)
    jwt_response = @client.enchanted_link_get_session(pending_ref)
    done = true
  rescue Descope::AuthException => e
    if e.status_code != 401
      p "Failed pending session, err: #{e}"
      done = true
    end
  end
end

if jwt_response
  refresh_token = jwt_response.fetch(Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME).fetch('jwt')
  @client.sign_out(refresh_token)
  p 'User logged out'
end
