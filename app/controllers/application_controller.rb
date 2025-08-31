# frozen_string_literal: true

class ApplicationController < ActionController::API
  # Centralized error handling for the application.
  # The order matters: more specific exceptions should be rescued before more general ones.

  # In production, rescue from all standard errors with a generic 500 response.
  # In development, this is skipped to allow the default error page to be shown for debugging.
  rescue_from StandardError, with: :handle_unexpected_error unless Rails.env.development?

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def record_invalid(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  def parameter_missing(error)
    render json: { error: error.message }, status: :bad_request
  end

  def handle_unexpected_error(error)
    # It's a good practice to log the actual error for debugging purposes.
    Rails.logger.error(error.full_message)
    render json: { error: 'An unexpected error occurred. Please try again later.' }, status: :internal_server_error
  end
end
