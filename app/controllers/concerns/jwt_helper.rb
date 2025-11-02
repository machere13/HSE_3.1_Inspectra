module JwtHelper
  extend ActiveSupport::Concern

  JWT_ISSUER = ENV.fetch('JWT_ISSUER', 'inspectra')
  JWT_AUDIENCE = ENV.fetch('JWT_AUDIENCE', 'inspectra-api')

  def jwt_secret
    JwtSecretService.current_secret
  end

  def encode_token(payload)
    payload[:exp] = 168.hours.from_now.to_i
    payload[:iss] = JWT_ISSUER
    payload[:aud] = JWT_AUDIENCE
    payload[:jti] = SecureRandom.uuid
    payload[:iat] = Time.current.to_i
    
    JWT.encode(payload, JwtSecretService.current_secret, 'HS256')
  end

  def decode_token(token)
    secret_for_decode = JwtSecretService.get_secret_for_decoding(token)
    return nil unless secret_for_decode
    
    decoded = JWT.decode(
      token, 
      secret_for_decode, 
      true, 
      { 
        algorithm: 'HS256',
        iss: JWT_ISSUER,
        verify_iss: true,
        aud: JWT_AUDIENCE,
        verify_aud: true
      }
    )[0]
    
    jti = decoded['jti']
    return nil if jti.blank?
    
    if RevokedToken.active.exists?(jti: jti)
      return nil
    end
    
    decoded
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidAudienceError
    nil
  end

  def revoke_token(token)
    secret_for_decode = JwtSecretService.get_secret_for_decoding(token)
    return false unless secret_for_decode
    
    decoded = JWT.decode(token, secret_for_decode, false)[0] rescue nil
    return false unless decoded
    
    jti = decoded['jti']
    expires_at = Time.at(decoded['exp']) if decoded['exp']
    
    return false if jti.blank? || expires_at.blank?
    
    RevokedToken.revoke(jti, expires_at)
    true
  end

  def auth_header
    request.headers['Authorization']
  end

  def token_from_header
    if auth_header
      auth_header.split(' ')[1]
    end
  end

  def current_user
    token = token_from_header
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find(decoded_token['user_id'])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def logged_in?
    !!current_user
  end

  def require_auth
    unless logged_in?
      render_authentication_required
      return false
    end
  end
end
