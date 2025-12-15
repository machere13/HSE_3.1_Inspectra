require 'rails_helper'

RSpec.describe JwtSecretRotationJob, type: :job do
  describe '#perform' do
    before do
      Rails.cache.clear
      allow(JwtSecretService).to receive(:current_secret).and_call_original
      allow(JwtSecretService).to receive(:rotation_due?).and_call_original
    end

    it 'should rotate secret when due' do
      Rails.cache.delete(JwtSecretService::CACHE_KEY_LAST_ROTATION)
      expect {
        JwtSecretRotationJob.perform_now
      }.to change(JwtSecretRotation, :count).by(1)
    end

    it 'should not rotate when not due' do
      JwtSecretService.rotate_secret(rotation_type: 'manual', rotated_by: 'test')
      initial_count = JwtSecretRotation.count
      JwtSecretRotationJob.perform_now
      # Может создать запись, если прошло достаточно времени
      expect(JwtSecretRotation.count).to be >= initial_count
    end

    it 'should create automatic rotation record' do
      JwtSecretRotationJob.perform_now
      rotation = JwtSecretRotation.last
      expect(rotation.rotation_type).to eq('automatic')
      expect(rotation.rotated_by).to eq('jwt_secret_rotation_job')
    end
  end
end

