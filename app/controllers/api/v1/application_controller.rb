# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      include ExceptionHandler

      private

      def render_json(data, status)
        render json: data, status:
      end

      def render_error_422_for(object)
        Rails.logger.debug { "\nERROR: #{object.attr_error_with_nested(object.class.name.underscore)}" }
        render_json(
          { success: false,
            errors: object.attr_error_with_nested(object.class.name.underscore) },
          :unprocessable_entity
        )
      end
    end
  end
end
