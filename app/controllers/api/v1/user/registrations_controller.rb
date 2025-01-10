# frozen_string_literal: true

module Api
  module V1
    module User
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        # Xử lý response khi đăng ký thành công
        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: { message: 'Signed up successfully', user: resource }, status: :ok
          else
            render json: { message: 'Sign up failed', errors: resource.errors.full_messages },
                   status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
