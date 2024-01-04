require 'sinatra'
require 'net/http'
require 'uri'
require 'json'
require 'descope'


# Server for token verification
class DescopeServer < Sinatra::Base
  attr_accessor :client

  def initialize(client: nil, project_id: nil)
    super
    raise Descope::AuthException, 'client and project id are required' if client.nil? && project_id.nil?

    @project_id = project_id
    @client = client || Descope::Client.new({ project_id: @project_id })
  end

  get '/verify' do
    token = params['t']

    if token.nil?
      status 400
      return 'Token is required'
    end

    begin
      response = @client.enchanted_link_verify_token(token: token)
      puts response

      # valid response is {}
      if response == {}
        status 200
        puts 'User clicked the link and token was verified!'
        return 'Token Verified!'
      else
        status 500
        puts 'Verification failed unexpected response'
        return 'Verification failed'
      end
    rescue => e
      puts "Could not verify token: #{e.message}"
      status 500
      return 'Verification failed'
    end
  end
end
