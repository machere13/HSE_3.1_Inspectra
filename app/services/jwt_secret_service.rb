class JwtSecretService
  CACHE_KEY_CURRENT = 'jwt_secret:current'
  CACHE_KEY_PREVIOUS = 'jwt_secret:previous'
  SECRET_TTL = 90.days

  def self.current_secret
    Rails.cache.fetch(CACHE_KEY_CURRENT) do
      generate_and_store_secret
    end
  end

  def self.previous_secret
    Rails.cache.read(CACHE_KEY_PREVIOUS)
  end

  def self.rotate_secret
    previous = current_secret
    new_secret = generate_secret
    
    Rails.cache.write(CACHE_KEY_PREVIOUS, previous, expires_in: SECRET_TTL)
    Rails.cache.write(CACHE_KEY_CURRENT, new_secret, expires_in: SECRET_TTL)
    
    new_secret
  end

  def self.get_secret_for_decoding(token)
    current = current_secret
    previous = previous_secret
    
    begin
      JWT.decode(token, current, false)
      return current
    rescue JWT::DecodeError
    end
    
    if previous
      begin
        JWT.decode(token, previous, false)
        return previous
      rescue JWT::DecodeError
      end
    end
    
    nil
  end

  private

  def self.generate_secret
    SecureRandom.hex(64)
  end

  def self.generate_and_store_secret
    secret = generate_secret
    Rails.cache.write(CACHE_KEY_CURRENT, secret, expires_in: SECRET_TTL)
    secret
  end
end
