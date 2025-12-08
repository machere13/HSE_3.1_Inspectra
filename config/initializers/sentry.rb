# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  
  config.enabled_environments = %w[production staging]
  
  config.environment = Rails.env
  
  config.release = ENV['SENTRY_RELEASE'] || ENV['HEROKU_SLUG_COMMIT'] || `git rev-parse HEAD`.chomp rescue nil
  
  config.traces_sample_rate = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', '0.1').to_f
  
  config.profiles_sample_rate = ENV.fetch('SENTRY_PROFILES_SAMPLE_RATE', '0.0').to_f
  
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
  config.send_default_pii = false
  
  config.before_send = lambda do |event, hint|
    if event.request && event.request.data
      %w[password password_confirmation current_password].each do |param|
        event.request.data[param] = '[FILTERED]' if event.request.data[param]
      end
    end
    
    if (user_id = Thread.current[:user_id])
      event.user = { id: user_id }
    end
    
    if (request_id = Thread.current[:request_id])
      event.tags = { request_id: request_id }
    end
    
    event
  end
  
  config.excluded_exceptions += [
    'ActionController::RoutingError',
    'ActionController::InvalidAuthenticityToken',
    'ActionDispatch::RemoteIp::IpSpoofAttackError',
    'Rack::Attack::Throttle'
  ]
  
  config.sdk_logger = Rails.logger
end

