module AppConfig
  extend self

  module JWT
    extend self

    def issuer
      ENV.fetch('JWT_ISSUER', Rails.application.credentials.dig(:jwt, :issuer) || 'inspectra')
    end

    def audience
      ENV.fetch('JWT_AUDIENCE', Rails.application.credentials.dig(:jwt, :audience) || 'inspectra-api')
    end

    def token_ttl_hours
      ENV.fetch('JWT_TOKEN_TTL_HOURS', '168').to_i.hours
    end

    def secret_ttl_days
      ENV.fetch('JWT_SECRET_TTL_DAYS', '90').to_i.days
    end

    def rotation_interval_days
      ENV.fetch('JWT_ROTATION_INTERVAL_DAYS', '30').to_i.days
    end

    def secret_length
      ENV.fetch('JWT_SECRET_LENGTH', '64').to_i
    end
  end

  module Auth
    extend self

    def verification_code_ttl_minutes
      ENV.fetch('VERIFICATION_CODE_TTL_MINUTES', '15').to_i.minutes
    end

    def reset_password_token_ttl_minutes
      ENV.fetch('RESET_PASSWORD_TOKEN_TTL_MINUTES', '30').to_i.minutes
    end

    def resend_code_cooldown_seconds
      ENV.fetch('RESEND_CODE_COOLDOWN_SECONDS', '60').to_i.seconds
    end

    def password_min_length
      ENV.fetch('PASSWORD_MIN_LENGTH', '8').to_i
    end

    def password_max_length
      ENV.fetch('PASSWORD_MAX_LENGTH', '64').to_i
    end
  end

  module Email
    extend self

    def default_username
      ENV.fetch('DEFAULT_EMAIL_USERNAME', Rails.application.credentials.dig(:email, :default_username))
    end

    def default_password
      ENV.fetch('DEFAULT_EMAIL_PASSWORD', Rails.application.credentials.dig(:email, :default_password))
    end

    def smtp_port
      ENV.fetch('SMTP_PORT', '587').to_i
    end
  end

  module Achievements
    extend self

    def default_consecutive_days
      ENV.fetch('DEFAULT_CONSECUTIVE_DAYS', '7').to_i
    end

    def recent_rotations_limit
      ENV.fetch('RECENT_ROTATIONS_LIMIT', '5').to_i
    end
  end

  module Content
    extend self

    def day_expiration_hours
      ENV.fetch('DAY_EXPIRATION_HOURS', '24').to_i.hours
    end

    def day_switch_hour
      ENV.fetch('DAY_SWITCH_HOUR', '0').to_i
    end

    def current_day
      ENV.fetch('CURRENT_DAY', nil)&.to_i
    end
  end

  module App
    extend self

    def mailer_host
      ENV.fetch('MAILER_HOST', 'localhost')
    end

    def json_logs?
      ENV.fetch('JSON_LOGS', 'false') == 'true'
    end

    def seed_type
      ENV.fetch('SEED', 'mock')
    end

    def log_level
      ENV.fetch('RAILS_LOG_LEVEL', 'info')
    end

    def log_to_file?
      ENV.fetch('LOG_TO_FILE', 'false') == 'true'
    end

    def log_file_path
      ENV.fetch('LOG_FILE_PATH', Rails.root.join('log', "#{Rails.env}.log").to_s)
    end
  end
end

