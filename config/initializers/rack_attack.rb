# Be sure to restart your server when you modify this file.

class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  throttle('api/auth/resend', limit: 5, period: 1.hour) do |req|
    if req.path == '/api/v1/auth/resend' && req.post?
      req.ip
    end
  end

  throttle('web/auth/resend', limit: 5, period: 1.hour) do |req|
    if req.path == '/auth/resend' && req.post?
      req.ip
    end
  end

  throttle('api/auth/password/forgot', limit: 5, period: 1.hour) do |req|
    if req.path == '/api/v1/auth/password/forgot' && req.post?
      req.ip
    end
  end

  throttle('web/auth/forgot', limit: 5, period: 1.hour) do |req|
    if req.path == '/auth/forgot' && req.post?
      req.ip
    end
  end

  throttle('api/auth/password/reset', limit: 5, period: 1.hour) do |req|
    if req.path == '/api/v1/auth/password/reset' && req.post?
      req.ip
    end
  end

  throttle('web/auth/reset', limit: 5, period: 1.hour) do |req|
    if req.path == '/auth/reset' && req.post?
      req.ip
    end
  end

  throttle('auth/ip', limit: 20, period: 1.hour) do |req|
    if req.path.start_with?('/api/v1/auth', '/auth') && req.post?
      req.ip
    end
  end

  self.throttled_response = lambda do |env|
    match_data = env['rack.attack.match_data']
    now = match_data[:epoch_time]
    
    headers = {
      'Content-Type' => 'application/json',
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - (now % match_data[:period]))).to_s
    }

    body = {
      success: false,
      error: {
        code: 'TOO_MANY_REQUESTS',
        message: 'Превышен лимит запросов. Попробуйте позже.'
      }
    }.to_json

    [429, headers, [body]]
  end
end

