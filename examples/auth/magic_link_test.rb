# frozen_string_literal: true
require 'sinatra'
require 'descope'
include Descope::Mixins::Common::DeliveryMethod

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
get '/verify' do
  token = params['t']

  if token.nil?
    status 400
    return 'Token is required'
  end

  begin
    response = @client.magiclink_email_verify_token(token: token)
    puts response
    puts "token is valid"
    refresh_token = jwt_response.fetch(Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME).fetch("jwt")
    puts "jwt_response: #{jwt_response}"
    status 200
    return 'Token Verified!'
  rescue => e
    puts "Could not verify token: #{e.message}"
    status 500
    return 'Verification failed'
  end
end


def sign_up_or_in(descope_client, login_id)
  res = descope_client.magiclink_email_sign_up_or_in(method: EMAIL, login_id:, uri: 'http://localhost:3001/verify')
  masked_email = res['maskedEmail']
  puts "masked_email: #{masked_email}"
end

def verify_magiclink(descope_client, token)
    begin

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



masked_email = sign_up_or_in(descope_client, 'ami+3@descope.com')
puts "We sent an email to #{masked_email}"

token = input(
  "Please insert the token you received by email (#{masked_email}):\n"
)


