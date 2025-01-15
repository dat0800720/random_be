# frozen_string_literal: true

module V1
  module User
    class UserSerializer < BaseSerializer
      attributes :id, :email
    end
  end
end
