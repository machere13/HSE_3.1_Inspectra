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

ENV['DEFAULT_EMAIL_USERNAME'] ||= 'test-sender@example.com'
ENV['DEFAULT_EMAIL_PASSWORD'] ||= 'test-password'

STUB_PNG_BYTES = "\x89PNG\r\n\x1a\n".freeze

if defined?(VerificationMailer)
  VerificationMailer.class_eval do
    def send_verification_code(user)
      @user = user
      @verification_code = user.verification_code
      attachments.inline['logo.png'] = {
        mime_type: 'image/png',
        content: STUB_PNG_BYTES,
        content_id: 'inspectra-logo'
      }
      mail(
        from: ENV['DEFAULT_EMAIL_USERNAME'] || 'test@example.com',
        to: user.email,
        subject: 'Код подтверждения'
      )
    end
  end
end

if defined?(ResetPasswordMailer)
  ResetPasswordMailer.class_eval do
    def reset_instructions
      @user = params[:user]
      attachments.inline['logo.png'] = {
        mime_type: 'image/png',
        content: STUB_PNG_BYTES,
        content_id: 'inspectra-logo'
      }
      mail(
        from: ENV['DEFAULT_EMAIL_USERNAME'] || 'test@example.com',
        to: @user.email,
        subject: 'Сброс пароля'
      )
    end
  end
end

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
