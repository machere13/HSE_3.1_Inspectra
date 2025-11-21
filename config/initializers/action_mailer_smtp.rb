Rails.application.config.to_prepare do
  if Rails.env.development?
    ActionMailer::Base.smtp_settings = {
      address: 'smtp.mail.ru',
      port: AppConfig::Email.smtp_port,
      domain: 'mail.ru',
      user_name: AppConfig::Email.default_username,
      password: AppConfig::Email.default_password,
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end
end

