class JwtSecretService
  CACHE_KEY_CURRENT = 'jwt_secret:current'
  CACHE_KEY_PREVIOUS = 'jwt_secret:previous'
  CACHE_KEY_LAST_ROTATION = 'jwt_secret:last_rotation'
  SECRET_TTL = 90.days
  ROTATION_INTERVAL = 30.days # Ротация каждые 30 дней

  def self.current_secret
    Rails.cache.fetch(CACHE_KEY_CURRENT) do
      generate_and_store_secret
    end
  end

  def self.previous_secret
    Rails.cache.read(CACHE_KEY_PREVIOUS)
  end

  def self.last_rotation_at
    Rails.cache.read(CACHE_KEY_LAST_ROTATION)
  end

  def self.rotation_due?
    last = last_rotation_at
    return true if last.nil?
    Time.current >= (last + ROTATION_INTERVAL)
  end

  def self.rotate_secret(rotation_type: 'manual', rotated_by: 'system', metadata: {})
    previous = current_secret
    new_secret = generate_secret
    
    Rails.cache.write(CACHE_KEY_PREVIOUS, previous, expires_in: SECRET_TTL)
    Rails.cache.write(CACHE_KEY_CURRENT, new_secret, expires_in: SECRET_TTL)
    Rails.cache.write(CACHE_KEY_LAST_ROTATION, Time.current, expires_in: SECRET_TTL)
    
    rotation = JwtSecretRotation.create!(
      rotated_at: Time.current,
      rotated_by: rotated_by,
      rotation_type: rotation_type,
      metadata: metadata.to_json
    )
    
    Rails.logger.info "[JWT Secret Rotation] Type: #{rotation_type}, By: #{rotated_by}, Rotation ID: #{rotation.id}"
    
    new_secret
  rescue => e
    Rails.logger.error "[JWT Secret Rotation Error] #{e.class}: #{e.message}"
    raise
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

  def self.rotation_stats
    {
      last_rotation: last_rotation_at,
      next_rotation_due: last_rotation_at ? (last_rotation_at + ROTATION_INTERVAL) : nil,
      rotation_due: rotation_due?,
      total_rotations: JwtSecretRotation.count,
      automatic_rotations: JwtSecretRotation.automatic.count,
      manual_rotations: JwtSecretRotation.manual.count,
      emergency_rotations: JwtSecretRotation.emergency.count,
      recent_rotations: JwtSecretRotation.recent.limit(5).map do |r|
        {
          id: r.id,
          rotated_at: r.rotated_at,
          rotated_by: r.rotated_by,
          rotation_type: r.rotation_type,
          metadata: r.metadata_hash
        }
      end
    }
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
