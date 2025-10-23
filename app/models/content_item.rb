class ContentItem < ApplicationRecord
  belongs_to :day

  KINDS = %w[image gif video audio link].freeze

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :day, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :validate_payload

  private

  def validate_payload
    case kind
    when 'image', 'gif', 'video', 'audio', 'link'
      errors.add(:url, 'must be present for media kind') if url.blank?
    end
  end
end
