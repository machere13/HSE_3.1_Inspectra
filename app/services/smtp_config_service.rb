class SmtpConfigService
  SMTP_CONFIGS = {
    'gmail.com' => {
      address: 'smtp.gmail.com',
      port: 587,
      domain: 'gmail.com',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'yandex.ru' => {
      address: 'smtp.yandex.ru',
      port: 587,
      domain: 'yandex.ru',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'yandex.com' => {
      address: 'smtp.yandex.ru',
      port: 587,
      domain: 'yandex.ru',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'mail.ru' => {
      address: 'smtp.mail.ru',
      port: 587,
      domain: 'mail.ru',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'bk.ru' => {
      address: 'smtp.mail.ru',
      port: 587,
      domain: 'mail.ru',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'list.ru' => {
      address: 'smtp.mail.ru',
      port: 587,
      domain: 'mail.ru',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'inbox.ru' => {
      address: 'smtp.mail.ru',
      port: 587,
      domain: 'mail.ru',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'outlook.com' => {
      address: 'smtp-mail.outlook.com',
      port: 587,
      domain: 'outlook.com',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'hotmail.com' => {
      address: 'smtp-mail.outlook.com',
      port: 587,
      domain: 'outlook.com',
      authentication: 'plain',
      enable_starttls_auto: true
    },
    'live.com' => {
      address: 'smtp-mail.outlook.com',
      port: 587,
      domain: 'outlook.com',
      authentication: 'plain',
      enable_starttls_auto: true
    }
  }.freeze

  def self.get_smtp_config(email)
    domain = email.to_s.split('@').last&.downcase
    return default_config unless domain
    
    config = SMTP_CONFIGS[domain]
    if config
      username = get_username_for_domain(domain) || ENV['DEFAULT_EMAIL_USERNAME']
      password = get_password_for_domain(domain) || ENV['DEFAULT_EMAIL_PASSWORD']
      
      config.merge(
        user_name: username,
        password: password
      )
    else
      default_config
    end
  end

  def self.supported_domains
    SMTP_CONFIGS.keys
  end

  private

  def self.get_username_for_domain(domain)
    case domain
    when 'gmail.com'
      ENV['GMAIL_USERNAME']
    when 'yandex.ru', 'yandex.com'
      ENV['YANDEX_USERNAME']
    when 'mail.ru', 'bk.ru', 'list.ru', 'inbox.ru'
      ENV['MAILRU_USERNAME']
    when 'outlook.com', 'hotmail.com', 'live.com'
      ENV['OUTLOOK_USERNAME']
    else
      ENV['DEFAULT_EMAIL_USERNAME']
    end
  end

  def self.get_password_for_domain(domain)
    case domain
    when 'gmail.com'
      ENV['GMAIL_PASSWORD']
    when 'yandex.ru', 'yandex.com'
      ENV['YANDEX_PASSWORD']
    when 'mail.ru', 'bk.ru', 'list.ru', 'inbox.ru'
      ENV['MAILRU_PASSWORD']
    when 'outlook.com', 'hotmail.com', 'live.com'
      ENV['OUTLOOK_PASSWORD']
    else
      ENV['DEFAULT_EMAIL_PASSWORD']
    end
  end

  def self.default_config
    {
      address: 'smtp.gmail.com',
      port: 587,
      domain: 'gmail.com',
      user_name: ENV['DEFAULT_EMAIL_USERNAME'],
      password: ENV['DEFAULT_EMAIL_PASSWORD'],
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end
end
