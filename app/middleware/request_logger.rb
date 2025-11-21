class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    start_time = Time.current
    
    return @app.call(env) if skip_logging?(request.path)
    
    Thread.current[:http_context] = {
      method: request.method,
      path: request.path,
      ip: request.remote_ip,
      user_agent: request.user_agent&.first(200),
      referer: request.referer&.first(200)
    }
    
    Thread.current[:metrics] = {
      db_queries: 0,
      db_time: 0.0,
      view_time: 0.0,
      total_time: 0.0
    }
    
    status, headers, response = @app.call(env)
    
    total_time = ((Time.current - start_time) * 1000).round(2)
    Thread.current[:metrics][:total_time] = total_time
    Thread.current[:http_context][:status] = status
    
    log_request(request, status, total_time)
    
    [status, headers, response]
  ensure
    Thread.current[:http_context] = nil
    Thread.current[:metrics] = nil
  end

  private

  def skip_logging?(path)
    path.start_with?('/up') ||
      path.start_with?('/assets') ||
      path.start_with?('/api-docs') ||
      path.start_with?('/rails')
  end

  def log_request(request, status, total_time)
    log_data = {
      method: request.method,
      path: request.path,
      status: status,
      duration_ms: total_time,
      ip: request.remote_ip
    }
    
    if (user_id = Thread.current[:user_id])
      log_data[:user_id] = user_id
    end
    
    if (metrics = Thread.current[:metrics])
      log_data.merge!(metrics)
    end
    
    level = case status
            when 200..299 then 'INFO'
            when 300..399 then 'INFO'
            when 400..499 then 'WARN'
            when 500..599 then 'ERROR'
            else 'INFO'
            end
    
    Rails.logger.public_send(level.downcase, "HTTP #{request.method} #{request.path} #{status} (#{total_time}ms)")
  end
end

