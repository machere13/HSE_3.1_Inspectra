class RevokedToken < ApplicationRecord
  validates :jti, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def self.revoke(jti, expires_at)
    find_or_create_by(jti: jti) do |token|
      token.expires_at = expires_at
    end
  end

  def self.cleanup_expired
    expired.delete_all
  end
end
