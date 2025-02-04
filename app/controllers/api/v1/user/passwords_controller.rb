# frozen_string_literal: true

module Api
  module V1
    module User
      class PasswordsController < Devise::PasswordsController
        def create
          self.resource = resource_class.send_reset_password_instructions resource_params
          if successfully_sent?(resource)
            render_json({ success: true }, :ok)
          else
            render_json({ success: false, errors: [key: :invalid_email] }, :unprocessable_entity)
          end
        end

        def edit # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          self.resource = resource_class.new
          set_minimum_password_length
          resource.reset_password_token = params[:reset_password_token]
          original_token       = params[:reset_password_token]
          reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
          recoverable = ::User.find_or_initialize_with_error_by(:reset_password_token, reset_password_token)

          unless recoverable.persisted?
            return render_json({ success: false, errors: [key: :record_not_found] },
                               :unprocessable_entity)
          end

          if recoverable.recoverable_expired?
            recoverable.errors.add(:reset_password_token, :expired)
            return render_json({ success: false, errors: recoverable.attr_error_with_nested(resource_name) },
                               :unprocessable_entity)
          end

          render_json({ success: true }, :ok)
        end

        def update
          self.resource = resource_class.reset_password_by_token resource_params
          if resource.errors.empty?
            resource.allowlisted_jwts.destroy_all
            render_json({ success: true }, :ok)
          else
            render_json({ success: false, errors: resource.attr_error_with_nested(resource_name) },
                        :unprocessable_entity)
          end
        end

        private

        def render_json(data, status)
          render json: data, status:
        end
      end
    end
  end
end
