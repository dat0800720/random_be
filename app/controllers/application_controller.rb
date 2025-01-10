# frozen_string_literal: true

class ApplicationController < ActionController::API
  private

  respond_to :json

  def render_json(data, status)
    render json: data, status:
  end
end
