# frozen_string_literal: true

require 'descope'

class SessionController < ApplicationController
  attr_reader :jwt_response

  before_action :authenticate_request


  def get_roles
    puts '🔐 Getting roles...'
    if @jwt_response['roles'].nil? || @jwt_response['roles'].empty?
      puts '🔐 Empty roles! You are not a trained Descope user!'
      return render json: { secretMessage: 'Empty roles! You are now a trained Descope user!', roles: [] }
    end

    roles = @jwt_response['roles']
    puts "🔐 Got Roles: #{roles}"
    render json: { secretMessage: 'You are now a trained Descope user!', roles: }
  end

  def get_role_data
    valid_student_role = descope_client.validate_roles(
      jwt_response: @jwt_response, roles: ['student']
    )
    valid_teacher_role = descope_client.validate_roles(
      jwt_response: @jwt_response, roles: ['teacher']
    )
    if valid_student_role && valid_teacher_role
      render json: { valid_teacher: valid_teacher_role, valid_student: valid_student_role }
    else
      render json: { valid_teacher: 'no valid teacher role found', valid_student: 'no valid student role found' }
    end
  end

  private

  def authenticate_request
    puts '🔐 Authenticating request...'
    unless request.headers['Authorization'].nil? # check if token is present in the request header
      auth_request = request.headers['Authorization']
      session_token = auth_request&.remove('Bearer ')
    end

    return render json: { error: '❌ Invalid session token!' }, status: :unauthorized unless session_token


    begin
      @jwt_response = descope_client.validate_session(session_token:)
    rescue Descope::AuthException
      return render json: { error: '❌ Invalid session token!' }, status: :unauthorized
    end

    logger.info "🔐 Authenticated successfully! token validated: #{@jwt_response}"
    @jwt_response
  end

  def descope_client
    @descope_client ||= Descope::Client.new({ project_id: APP_CONFIG['react_app_project_id'], log_level: APP_CONFIG['ruby_sdk_log_level'] })
  rescue Descope::AuthException => e
    logger.error "Failed to initialize descope sdk: #{e.message}"

  end

end
