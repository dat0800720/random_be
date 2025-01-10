# frozen_string_literal: true

module Api
  module V1
    module User
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          render json: { message: 'Logged in successfully', user: resource }, status: :ok
        end

        def respond_to_on_destroy
          jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last,
                                   Rails.application.credentials.devise_jwt_secret_key).first
          current_user = User.find(jwt_payload['sub'])
          if current_user
            render json: { message: 'Logged out successfully' }, status: :ok
          else
            render json: { message: 'Failed to log out' }, status: :unauthorized
          end
        end
      end
    end
  end
end
