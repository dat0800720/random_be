# frozen_string_literal: true

module Api
  module V1
    module User
      class RegistrationsController < Devise::RegistrationsController
        include SkipSession

        def create
          build_resource(sign_up_params)

          if resource.save
            sign_in(resource_name, resource)
            render_json({ success: true, data: resource }, :ok)
          else
            render_json({ success: false, errors: resource.attr_error_with_nested(resource_name) },
                        :unprocessable_entity)
          end
        end

        private

        def render_json(data, status)
          render json: data, status:
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
