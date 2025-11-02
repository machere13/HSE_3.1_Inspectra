class ResetPasswordMailer < ApplicationMailer
  def reset_instructions
    @user = params[:user]
    @reset_url = reset_url(@user.reset_password_token)
    sender_email = ENV['DEFAULT_EMAIL_USERNAME']
    smtp_config = SmtpConfigService.get_smtp_config(sender_email)

    mail(
      from: sender_email,
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


