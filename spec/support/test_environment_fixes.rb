if defined?(ActionDispatch::HostAuthorization)
  ActionDispatch::HostAuthorization.class_eval do
    def call(env)
      @app.call(env)
    end
  end
end

if defined?(Rack::Attack)
  Rack::Attack.enabled = false
end

if defined?(ActiveJob::Base)
  ActiveJob::Base.queue_adapter = :test
end

if defined?(ActionController::Base)
  ActionController::Base.allow_forgery_protection = false
end
if defined?(ActionController::API)
  ActionController::API.allow_forgery_protection = false if ActionController::API.respond_to?(:allow_forgery_protection=)
end

# Mailers (VerificationMailer/ResetPasswordMailer) берут `from:` из ENV.
# В test env переменные могут отсутствовать → mail(from: nil) → 500.
# Реальной отправки нет (config.action_mailer.delivery_method = :test).
ENV['DEFAULT_EMAIL_USERNAME'] ||= 'test-sender@example.com'
ENV['DEFAULT_EMAIL_PASSWORD'] ||= 'test-password'

RSpec.configure do |config|
  config.before(:suite) do
    [InteractiveCompletion, InteractiveAttempt, InteractiveVariant, Interactive,
     UserTitle, UserAchievement, Achievement, Title, Level,
     ContentItem, Article, Week,
     MediaSubscription, ErrorReport, RevokedToken].each do |model|
      next unless defined?(model)
      begin
        User.update_all(current_title_id: nil) if model == Title && User.column_names.include?('current_title_id')
        model.delete_all
      rescue ActiveRecord::StatementInvalid => e
        warn "[spec] cleanup #{model} failed: #{e.message}"
      end
    end

    User.delete_all if defined?(User)
  end
end
