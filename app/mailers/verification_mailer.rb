class VerificationMailer < ApplicationMailer
  def send_verification_code(user)
    @user = user
    @verification_code = user.verification_code
    sender_email = ENV['DEFAULT_EMAIL_USERNAME']
    smtp_config = SmtpConfigService.get_smtp_config(sender_email)

    logo_path = Rails.root.join('app/assets/images/mailers/Logo.png')
    attachments.inline['logo.png'] = {
      mime_type: 'image/png',
      content: File.binread(logo_path),
      content_id: 'inspectra-logo'
    }

    mail(
      from: sender_email,
      to: @user.email, 
      subject: 'Код подтверждения',
      delivery_method_options: smtp_config
    )
  end
end
