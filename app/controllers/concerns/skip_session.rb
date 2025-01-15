# frozen_string_literal: true

module SkipSession
  extend ActiveSupport::Concern

  included do
    before_action :skip_session
  end

  private

  def skip_session
    request.session_options[:skip] = true
  end
end
