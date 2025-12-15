require 'rails_helper'

RSpec.describe JwtSecretService, type: :service do
  before do
    Rails.cache.clear
    RSpec::Mocks.space.proxy_for(JwtSecretService).remove_stub(:current_secret) if RSpec::Mocks.space.proxy_for(JwtSecretService)
    RSpec::Mocks.space.proxy_for(JwtSecretService).remove_stub(:previous_secret) if RSpec::Mocks.space.proxy_for(JwtSecretService)
    RSpec::Mocks.space.proxy_for(JwtSecretService).remove_stub(:get_secret_for_decoding) if RSpec::Mocks.space.proxy_for(JwtSecretService)
  end

  describe '.current_secret' do
    it 'should generate and return secret' do
      secret = JwtSecretService.current_secret
      expect(secret).to be_present
      expect(secret.length).to be > 0
    end

    it 'should cache secret' do
      secret1 = JwtSecretService.current_secret
      secret2 = JwtSecretService.current_secret
      expect(secret1).to eq(secret2)
    end
  end

  describe '.rotate_secret' do
    it 'should generate new secret' do
      old_secret = JwtSecretService.current_secret
      new_secret = JwtSecretService.rotate_secret(rotation_type: 'manual', rotated_by: 'test')
      expect(new_secret).not_to eq(old_secret)
      expect(JwtSecretService.current_secret).to eq(new_secret)
    end

    it 'should store previous secret' do
      old_secret = JwtSecretService.current_secret
      JwtSecretService.rotate_secret(rotation_type: 'manual', rotated_by: 'test')
      expect(JwtSecretService.previous_secret).to eq(old_secret)
    end

    it 'should create rotation record' do
      expect {
        JwtSecretService.rotate_secret(rotation_type: 'manual', rotated_by: 'test')
      }.to change(JwtSecretRotation, :count).by(1)
    end
  end

  describe '.rotation_due?' do
    it 'should return true if never rotated' do
      Rails.cache.delete(JwtSecretService::CACHE_KEY_LAST_ROTATION)
      expect(JwtSecretService.rotation_due?).to be true
    end

    it 'should return false if recently rotated' do
      JwtSecretService.rotate_secret(rotation_type: 'manual', rotated_by: 'test')
      expect(JwtSecretService.rotation_due?).to be false
    end
  end

  describe '.get_secret_for_decoding' do
    it 'should return current secret for valid token' do
      secret = JwtSecretService.current_secret
      token = JWT.encode({ user_id: 1 }, secret, 'HS256')
      expect(JwtSecretService.get_secret_for_decoding(token)).to eq(secret)
    end

    it 'should return previous secret for old token' do
      old_secret = JwtSecretService.current_secret
      old_token = JWT.encode({ user_id: 1 }, old_secret, 'HS256')
      JwtSecretService.rotate_secret(rotation_type: 'manual', rotated_by: 'test')
      expect(JwtSecretService.get_secret_for_decoding(old_token)).to eq(old_secret)
    end

    it 'should return nil for invalid token' do
      invalid_token = 'invalid.token.here'
      result = JwtSecretService.get_secret_for_decoding(invalid_token)
      # Может вернуть nil или выбросить исключение
      expect(result).to be_nil
    rescue JWT::DecodeError
      # Это тоже нормально для невалидного токена
    end
  end

  describe '.rotation_stats' do
    it 'should return rotation statistics' do
      JwtSecretService.rotate_secret(rotation_type: 'manual', rotated_by: 'test')
      stats = JwtSecretService.rotation_stats
      expect(stats).to have_key(:last_rotation)
      expect(stats).to have_key(:total_rotations)
      expect(stats[:total_rotations]).to be >= 1
    end
  end
end

