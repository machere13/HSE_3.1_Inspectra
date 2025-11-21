if Rails.env.production? || AppConfig::App.json_logs?
  require_relative '../../app/middleware/request_logger'
  Rails.application.config.middleware.insert_after ActionDispatch::RequestId, RequestLogger
end

