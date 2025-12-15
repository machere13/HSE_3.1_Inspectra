require 'rails_helper'

RSpec.describe RevokedToken, type: :model do
  let(:revoked_token) do
    RevokedToken.new(
      jti: SecureRandom.uuid,
      expires_at: 1.hour.from_now
    )
  end

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(revoked_token).to be_valid
    end

    it 'should require jti' do
      revoked_token.jti = nil
      expect(revoked_token).not_to be_valid
    end

    it 'should require unique jti' do
      revoked_token.save!
      duplicate = RevokedToken.new(jti: revoked_token.jti, expires_at: 1.hour.from_now)
      expect(duplicate).not_to be_valid
    end

    it 'should require expires_at' do
      revoked_token.expires_at = nil
      expect(revoked_token).not_to be_valid
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'should return only non-expired tokens' do
        active = RevokedToken.create!(jti: SecureRandom.uuid, expires_at: 1.hour.from_now)
        expired = RevokedToken.create!(jti: SecureRandom.uuid, expires_at: 1.hour.ago)
        expect(RevokedToken.active).to include(active)
        expect(RevokedToken.active).not_to include(expired)
      end
    end

    describe '.expired' do
      it 'should return only expired tokens' do
        active = RevokedToken.create!(jti: SecureRandom.uuid, expires_at: 1.hour.from_now)
        expired = RevokedToken.create!(jti: SecureRandom.uuid, expires_at: 1.hour.ago)
        expect(RevokedToken.expired).to include(expired)
        expect(RevokedToken.expired).not_to include(active)
      end
    end
  end

  describe '.revoke' do
    it 'should create revoked token' do
      jti = SecureRandom.uuid
      expires_at = 1.hour.from_now
      token = RevokedToken.revoke(jti, expires_at)
      expect(token).to be_persisted
      expect(token.jti).to eq(jti)
    end

    it 'should find existing token if already revoked' do
      jti = SecureRandom.uuid
      expires_at = 1.hour.from_now
      token1 = RevokedToken.revoke(jti, expires_at)
      token2 = RevokedToken.revoke(jti, expires_at)
      expect(token1.id).to eq(token2.id)
    end
  end

  describe '.cleanup_expired' do
    it 'should delete expired tokens' do
      active = RevokedToken.create!(jti: SecureRandom.uuid, expires_at: 1.hour.from_now)
      expired = RevokedToken.create!(jti: SecureRandom.uuid, expires_at: 1.hour.ago)
      RevokedToken.cleanup_expired
      expect(RevokedToken.find_by(id: expired.id)).to be_nil
      expect(RevokedToken.find_by(id: active.id)).to be_present
    end
  end
end
