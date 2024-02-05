# frozen_string_literal: true

require 'time'
require 'mailmock'
require 'net/http'
require 'uri'
require 'json'
require 'securerandom'

module Mailmock
  class Client
    attr_accessor :api

    def initialize(config = {})
      configuration = Mailmock::Configuration.new
      configuration.host = config[:host] || 'mailmock.io'
      configuration.base_path = config[:base_path] || '/api/trpc'
      configuration.scheme = config[:schema] || 'https'
      configuration.debugging = config[:debugging] || false

      api_client = Mailmock::ApiClient.new(configuration)
      @api = Mailmock::EmailApi.new(api_client)
    end
  end

  class Mail
    attr_accessor :client, :mailbox, :user

    def initialize(debugging = false)
      @client = create_client(debugging)
    end

    def create_mailbox(user, provider)
      begin
        puts "Creating a new mailbox for user: #{user} with provider: #{provider}"
        email_request = Mailmock::EmailCreateRequest.new({ user:, provider: })
        @user = user
        @mailbox = @client.api.email_create(email_request)
        puts "Mailbox created: #{@mailbox}"
        @mailbox
      rescue Mailmock::ApiError => e
        puts "Error could not create mailbox: #{e}"
      end
    end

    def wait_for_email(timeout = 30)
      puts "Checking for mail every second for #{timeout} seconds"
      begin
        Timeout::timeout(timeout) do
          loop do
            emails = @client.api.email_list({ user: @user, mailbox: @mailbox.mailbox, unread: "true" })

            if emails.empty?
              puts "No new email yet"
              sleep(1)
            else
              puts "You've got mail! #{emails}"
              email_read_request = Mailmock::EmailReadRequest.new({ message_id: emails[0].message_id })
              email = @client.api.email_read(email_read_request)
              return email
            end
          end
        end
      rescue Timeout::Error
        puts "Timed out while waiting for new email"
      rescue => e
        puts "Error: #{e.message}"
        exit 1
      end
    end

    private

    def create_client(debugging = false)
      Client.new({ debugging: })
    end
  end
end
