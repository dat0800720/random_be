# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :allowlisted_jwts, dependent: :destroy

  def recoverable_expired?
    reset_password_sent_at.present? && reset_password_sent_at < self.class.reset_password_within.ago
  end
end
