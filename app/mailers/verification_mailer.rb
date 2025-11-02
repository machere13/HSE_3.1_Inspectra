class VerificationMailer < ApplicationMailer
  def send_verification_code(user)
    @user = user
    @verification_code = user.verification_code
    sender_email = ENV['DEFAULT_EMAIL_USERNAME']
    smtp_config = SmtpConfigService.get_smtp_config(sender_email)

    mail(
      from: sender_email,
      to: @user.email, 
      subject: 'Код подтверждения',
      delivery_method_options: smtp_config
    )
  end
end
