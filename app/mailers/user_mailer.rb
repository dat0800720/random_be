# frozen_string_literal: true

class UserMailer < Devise::Mailer
  default from: '0807damducdat@gmail.com'

  # Gửi email đặt lại mật khẩu
  def reset_password_instructions(record, token, _opts = {})
    @token = token
    @resource = record
    mail(to: record.email, subject: 'Hướng dẫn đặt lại mật khẩu')
  end
end
