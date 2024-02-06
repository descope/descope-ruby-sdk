# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'

describe Descope::Api::V1::Auth::OAuth do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
    @driver = Selenium::WebDriver.for :chrome
  end

  context 'test OAuth methods' do
    it 'should sign up with OAuth Github' do
      user = ENV['SANITY_GITHUB_EMAIL']
      password = ENV['SANITY_GITHUB_PASSWORD']

      start_url = @client.oauth_start(provider: 'github', return_url: 'http://127.0.0.1:1234/path')['url']
      puts "Start URL: #{start_url}"
      @driver.navigate.to start_url
      @driver.find_element(:id, 'login_field').send_keys(user)
      @driver.find_element(:id, 'password').send_keys(password)
      @driver.find_element(:name, 'commit').click

      # Handle Confirmation page
      begin
        puts 'Confirmation page found'
        @driver.find_element(:id, 'js-oauth-authorize-btn').click
      rescue Selenium::WebDriver::Error::NoSuchElementError
        puts 'could not find confirmation button'
        # Handle case where confirmation page isn't present
      end

      # Parse returned code from URL
      current_url = @driver.current_url
      puts "Current URL: #{current_url}"
      parsed_url = URI.parse(current_url)
      code = CGI.parse(parsed_url.query)['code'].first
      puts "Code: #{code}"

      # Exchange code for token
      token = @client.oauth_exchange_token(code)
      puts "Token: #{token}"
      my_details = @client.me(token[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME]['jwt'])
      puts "My Details: #{my_details}"
    ensure
      @driver.quit
    end
  end
end
