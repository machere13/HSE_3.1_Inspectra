require 'rails_helper'

RSpec.describe JwtSecretRotation, type: :model do
  let(:rotation) do
    JwtSecretRotation.new(
      rotated_at: Time.current,
      rotated_by: 'test_user',
      rotation_type: 'manual'
    )
  end

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(rotation).to be_valid
    end

    it 'should require rotated_at' do
      rotation.rotated_at = nil
      expect(rotation).not_to be_valid
    end

    it 'should require rotated_by' do
      rotation.rotated_by = nil
      expect(rotation).not_to be_valid
    end

    it 'should require rotation_type' do
      rotation.rotation_type = nil
      expect(rotation).not_to be_valid
    end

    it 'should require rotation_type to be in ROTATION_TYPES' do
      rotation.rotation_type = 'invalid'
      expect(rotation).not_to be_valid
    end
  end

  describe 'scopes' do
    describe '.recent' do
      it 'should order by rotated_at desc' do
        old = JwtSecretRotation.create!(
          rotated_at: 2.days.ago,
          rotated_by: 'test',
          rotation_type: 'manual'
        )
        new = JwtSecretRotation.create!(
          rotated_at: 1.day.ago,
          rotated_by: 'test',
          rotation_type: 'manual'
        )
        expect(JwtSecretRotation.recent.first).to eq(new)
      end
    end

    describe '.automatic' do
      it 'should return only automatic rotations' do
        automatic = JwtSecretRotation.create!(
          rotated_at: Time.current,
          rotated_by: 'test',
          rotation_type: 'automatic'
        )
        manual = JwtSecretRotation.create!(
          rotated_at: Time.current,
          rotated_by: 'test',
          rotation_type: 'manual'
        )
        expect(JwtSecretRotation.automatic).to include(automatic)
        expect(JwtSecretRotation.automatic).not_to include(manual)
      end
    end
  end

  describe '#metadata_hash' do
    it 'should parse JSON metadata' do
      rotation.metadata = '{"key": "value"}'
      expect(rotation.metadata_hash).to eq({ 'key' => 'value' })
    end

    it 'should return empty hash for blank metadata' do
      rotation.metadata = nil
      expect(rotation.metadata_hash).to eq({})
    end

    it 'should return empty hash for invalid JSON' do
      rotation.metadata = 'invalid json'
      expect(rotation.metadata_hash).to eq({})
    end
  end
end

