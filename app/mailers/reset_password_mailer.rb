class ResetPasswordMailer < ApplicationMailer
  def reset_instructions
    @user = params[:user]
    @reset_url = reset_url(@user.reset_password_token)
    smtp_config = SmtpConfigService.get_smtp_config(@user.email)

    mail(
      from: ENV['DEFAULT_EMAIL_USERNAME'],
      to: @user.email, 
      subject: 'Сброс пароля',
      delivery_method_options: smtp_config
    )
  end

  private

  def reset_url(token)
    root_url + "reset_password?token=#{token}"
  end
end


