require 'sinatra'
require 'net/http'
require 'uri'
require 'json'


get '/verify' do
  token = params['t']

  if token.nil?
    status 400
    return 'Token is required'
  end

  uri = URI.parse('https://api.descope.org/v1/auth/enchantedlink/verify')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{P2P3hlbsUIyy5H65B56jEE9oXZXD}" })
  request.body = { token: token }.to_json


  begin
    response = http.request(request)
    puts response.body
    status 200
    puts 'User clicked the link and token was verified!'
    return 'Token Verified!'
  rescue => e
    puts "Verification failed: #{e.message}"
    status 500
    return 'Verification failed'
  end
end

set :port, 3001