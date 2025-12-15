module JwtTestHelper
  SECRET = 'test-jwt-secret'.freeze
  JWT_ISSUER = ENV.fetch('JWT_ISSUER', 'inspectra')
  JWT_AUDIENCE = ENV.fetch('JWT_AUDIENCE', 'inspectra-api')

  def encode_test_jwt(payload)
    payload = payload.dup
    payload[:exp] = AppConfig::JWT.token_ttl_hours.from_now.to_i
    payload[:iss] = AppConfig::JWT.issuer
    payload[:aud] = AppConfig::JWT.audience
    payload[:jti] = SecureRandom.uuid
    payload[:iat] = Time.current.to_i

    JWT.encode(payload, SECRET, 'HS256')
  end

  def stub_jwt_secret_store
    allow(JwtSecretService).to receive(:current_secret).and_return(SECRET)
    allow(JwtSecretService).to receive(:previous_secret).and_return(nil)
    allow(JwtSecretService).to receive(:get_secret_for_decoding).and_return(SECRET)
  end
end

RSpec.configure do |config|
  config.include JwtTestHelper

  config.before(:each) do |example|
    unless example.metadata[:file_path].include?('jwt_secret_service_spec.rb')
      stub_jwt_secret_store
    end
  end
end
