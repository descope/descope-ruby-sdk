# frozen_string_literal: true

require 'descope'
# sdx mgmt key suffix => K2aTAgKcLXTi04pnug58FMhmVw6x
sdx_project_id = 'P2OkfVnJi5Ht7mpCqHjx17nV5epH'
sdx_management_key = 'K2aTm0tKOrwsgQfkO2a1w5SQkHUGMl6mPVv5bA7FWxWuxNFPTfVfF6WsqXGlLYykMAUxtt1'
descope_client = Descope::Client.new(
  {
    project_id: sdx_project_id
  }
)
# descope_client.load_by_user_id(user_id: 'U2Zs5oaPIAtUumVXIlwPjTlVmGlI')

res = descope_client.enchanted_link_sign_up_or_in(login_id: 'kevin+2@descope.com', uri: 'http://localhost:3001/verify')
link_identifier = res['linkId'] # Show the user which link they should press in their email
pending_ref = res['pendingRef'] # Used to poll for a valid session
masked_email = res['maskedEmail']
puts "masked_email: #{masked_email}"
puts "link_identifier: #{link_identifier}"
# After sending the link, you must poll to receive a valid session using the pending_ref from the previous step.
# A valid session will be returned only after the user clicks the right link
session_token = ''
refresh_token = ''

done = false
max_tries = 30
i = 0
while !done && i < max_tries
  begin
    i += 1
    puts 'waiting 4 seconds for session to be created...'
    puts "link_identifier: #{link_identifier}"
    sleep(4)
    jwt_response = descope_client.enchanted_link_get_session(pending_ref: pending_ref)
  rescue Descope::AuthException, Descope::Unauthorized => e
    puts "Failed pending session, err: #{e}"
    nil
  end

  if jwt_response
    session_token = jwt_response[SESSION_TOKEN_NAME].get('jwt')
    refresh_token = jwt_response[REFRESH_SESSION_TOKEN_NAME].get('jwt')

    puts "session_token: #{session_token}"
    puts "refresh_token: #{refresh_token}"
    break
  end
end


  # To verify an enchanted link, your redirect page must call the validation function on the token (t) parameter
  # (https://your-redirect-address.com/verify?t=<token>). Once the token is verified, the session polling will receive a valid jwt_response.
begin
  descope_client.enchanted_link_verify_token(token: session_token)
rescue Descope::AuthException => e
  puts "Failed to verify enchanted link token, err: #{e}"
end
  # The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on session validation

# https://app.descope.org/login?descope-login-flow=sign-up-or-in%7C%23%7C2aTJFM1QZK7uPdbeB7DN72ln9yc_36.end-2aTJIxFMgo8N5UoqU5hDQDXSstI
# &t=76897645235c1c864c4221bbb7eb2eea8d7c438e8a25972f13b9d15b4a96e7cf