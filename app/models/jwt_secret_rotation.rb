class JwtSecretRotation < ApplicationRecord
  ROTATION_TYPES = %w[automatic manual emergency].freeze

  validates :rotated_at, presence: true
  validates :rotated_by, presence: true
  validates :rotation_type, presence: true, inclusion: { in: ROTATION_TYPES }

  scope :recent, -> { order(rotated_at: :desc) }
  scope :automatic, -> { where(rotation_type: 'automatic') }
  scope :manual, -> { where(rotation_type: 'manual') }
  scope :emergency, -> { where(rotation_type: 'emergency') }

  def metadata_hash
    return {} if metadata.blank?
    JSON.parse(metadata)
  rescue JSON::ParserError
    {}
  end
end

