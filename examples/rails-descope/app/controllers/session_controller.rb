# frozen_string_literal: true

require 'descope'

class SessionController < ApplicationController
  before_action :authenticate_request


  def get_roles
    return { secretMessage: 'Empty roles! You are not a trained Descope user!' } if @jwt_response['roles'].nil?

    roles = @jwt_response['roles']
    { "secretMessage": 'You are now a trained Descope user!', "roles": roles }
  end

  def get_role_data
    valid_student_role = descope_client.validate_roles(
      jwt_response: @jwt_response, roles: ['student']
    )
    valid_teacher_role = descope_client.validate_roles(
      jwt_response: @jwt_response, roles: ['teacher']
    )

    { "valid_teacher": valid_teacher_role, "valid_student": valid_student_role }
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
      @jwt_response = descope_client.validate_token(session_token)
    rescue Descope::AuthException
      return render json: { error: '❌ Invalid session token!' }, status: :unauthorized
    end

    logger.info "🔐 Authenticated successfully! token validated: #{@jwt_response}"
    @jwt_response
  end

  def descope_client
    begin
      @descope_client ||= Descope::Client.new({ project_id: 'P2aVGmQvQzSLJwP3ttcxO12tmQXk', log_level: 'debug' })
    rescue Descope::AuthException => e
      logger.error "Failed to initialize descope sdk: #{e.message}"
    end
  end

end
