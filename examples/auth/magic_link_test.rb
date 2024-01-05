# frozen_string_literal: true

require 'descope'
require_relative 'server.rb'

# prod
# DESCOPE_PROJECT_ID = 'P2aVGmQvQzSLJwP3ttcxO12tmQXk'

# sandbox
DESCOPE_PROJECT_ID = 'P2aVMzUiPwXNXQ8HSJOvZN76fOUW'

descope_client = Descope::Client.new(
  {
    project_id: DESCOPE_PROJECT_ID,
    descope_base_uri: 'https://api.descope.org'
  }
)

# Initialize our Sinatra application
descope_app = DescopeServer.new(client: descope_client)

Thread.new do
  begin
    Rack::Handler::WEBrick.run descope_app, Port: 3001
  rescue => Interrupt
    puts 'Sinatra server shutting down...'
    nil
  end
end

def sign_up_or_in(descope_client, login_id)
  res = descope_client.magic_link_email_sign_up_or_in(login_id:, uri: 'http://localhost:3001/verify')
  link_identifier = res['linkId'] # Show the user which link they should press in their email
  pending_ref = res['pendingRef'] # Used to poll for a valid session
  masked_email = res['maskedEmail']
  puts "masked_email: #{masked_email}"
  puts "link_identifier: #{link_identifier}"
  puts "pending_ref: #{pending_ref}"
  pending_ref
end

def poll_for_session(descope_client, pending_ref)
  max_tries = 15
  i = 0
  done = false
  while !done && i < max_tries
    begin
      i += 1
      puts 'waiting 4 seconds for session to be created...'
      sleep(4)
      print '.'
      jwt_response = descope_client.enchanted_link_get_session(pending_ref:)
      done = true
    rescue Descope::AuthException, Descope::Unauthorized => e
      puts "Failed pending session, err: #{e}"
      nil
    end

    if jwt_response
      puts "jwt_response: #{jwt_response}"
      refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME]['jwt']

      puts "refresh_token: #{refresh_token}"
      puts :"Done logging out!"
      descope_client.sign_out(refresh_token)
      puts 'User logged out'
      done = true
    end
  end
end



pending_ref = sign_up_or_in(descope_client, 'ami+3@descope.com')
poll_for_session(descope_client, pending_ref)
# After sending the link, you must poll to receive a valid session using the pending_ref from the previous step.
# A valid session will be returned only after the user clicks the right link
# this will be intercepted by the sinatra server and the token will be verified
# once the token is verified, the session will be created and returned as session_token and refresh_token
