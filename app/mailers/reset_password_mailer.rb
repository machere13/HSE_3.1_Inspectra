class ResetPasswordMailer < ApplicationMailer
  def reset_instructions
    @user = params[:user]
    @reset_url = reset_url(@user.reset_password_token)
    DynamicSmtpMailer.send_with_dynamic_smtp(@user.email) do
      mail(
        from: ENV['DEFAULT_EMAIL_USERNAME'],
        to: @user.email, subject: 'Сброс пароля'
      )
    end
  end

  private

  def reset_url(token)
    root_url + "reset_password?token=#{token}"
  end
end


