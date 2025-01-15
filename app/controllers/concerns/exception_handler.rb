# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern
  include ResponseHelper

  included do # rubocop:disable Metrics/BlockLength
    rescue_from StandardError do |e|
      handle_500(:standard_error, e)
    end
    rescue_from ActiveRecord::RecordNotFound do |e|
      handle_404(:record_not_found, { resource: e.model, id: e.id })
    end
    rescue_from JWT::DecodeError do |_e|
      handle_400(:token_invalid)
    end
    rescue_from JWT::ExpiredSignature do |_e|
      handle_400(:token_expired)
    end
    rescue_from JWT::VerificationError do |_e|
      handle_400(:token_invalid)
    end
    rescue_from Warden::JWTAuth::Errors::RevokedToken do |_e|
      handle_400(:token_revoked)
    end
    rescue_from ActionController::RoutingError do |_e|
      handle_404(:routing_error)
    end
    rescue_from ActiveRecord::RecordInvalid do |_e|
      handle_422(:record_invalid)
    end
    rescue_from ActionController::ParameterMissing do |_e|
      handle_400(:bad_request)
    end
    # rescue_from Pundit::NotAuthorizedError do |_e|
    #   handle_401(:not_permission)
    # end
  end

  private

  def handle_500(key, exception = nil)
    log_message = '500 Internal Server Error'
    log_message += "- Exception: #{exception.message}" if exception
    logger.error log_message
    logger.error exception.backtrace.first(50).join("\n")
    str = log_message + exception.backtrace.first(20).join("\n")
    render_error(500, "#{key}\n#{str}")
  end

  def handle_422(key, options = {})
    render_error(422, key, options)
  end

  def handle_404(key, options = {})
    render_error(404, key, options)
  end

  def handle_400(key)
    render_error(400, key)
  end

  def handle_401(key)
    render_error(401, key)
  end
end
