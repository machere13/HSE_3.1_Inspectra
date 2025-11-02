class VerificationMailer < ApplicationMailer
  def send_verification_code(user)
    @user = user
    @verification_code = user.verification_code
    smtp_config = SmtpConfigService.get_smtp_config(@user.email)

    mail(
      from: ENV['DEFAULT_EMAIL_USERNAME'],
      to: @user.email, 
      subject: 'Код подтверждения',
      delivery_method_options: smtp_config
    )
  end
end
