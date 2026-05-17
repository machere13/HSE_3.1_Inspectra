if defined?(ActionDispatch::HostAuthorization)
  ActionDispatch::HostAuthorization.class_eval do
    def call(env)
      @app.call(env)
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
