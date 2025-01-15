# frozen_string_literal: true

module Api
  module V1
    module User
      class SessionsController < Devise::SessionsController
        skip_before_action :require_no_authentication, only: :create

        private

        def respond_with(resource, _opts = {})
          if current_user
            render_json({ success: true, data: ::V1::User::UserSerializer.build_response(resource) }, :ok)
          else
            render_json(
              { success: false, errors: resource.attr_error_with_nested(resource_name) },
              :unprocessable_entity
            )
          end
        end

        def respond_to_on_destroy
          head :ok
        end

        def render_json(data, status)
          render json: data, status:
        end
      end
    end
  end
end
