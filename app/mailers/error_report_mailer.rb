class ErrorReportMailer < ApplicationMailer
  def new_report(report)
    @report = report
    sender_email = ENV['DEFAULT_EMAIL_USERNAME']
    smtp_config = SmtpConfigService.get_smtp_config(sender_email)
    recipients = User.where(role: [:admin, :super_admin]).pluck(:email).compact_blank.uniq
    return if recipients.empty?

    logo_path = Rails.root.join('app/assets/images/mailers/Logo.png')
    attachments.inline['logo.png'] = {
      mime_type: 'image/png',
      content: File.binread(logo_path),
      content_id: 'inspectra-logo'
    }

    mail(
      from: sender_email,
      to: recipients,
      subject: "Новый report #{report.status_code.presence || 'без кода'}",
      delivery_method_options: smtp_config
    )
  end
end
