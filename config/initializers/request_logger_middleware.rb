if Rails.env.production? || AppConfig::App.json_logs?
  Rails.application.config.middleware.insert_after ActionDispatch::RequestId, RequestLogger
end

