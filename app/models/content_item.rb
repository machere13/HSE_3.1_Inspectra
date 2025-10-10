class ContentItem < ApplicationRecord
  belongs_to :day
  belongs_to :article, optional: true

  KINDS = %w[image gif video audio link article].freeze

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :day, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :validate_payload

  private

  def validate_payload
    case kind
    when 'article'
      errors.add(:article, 'must be present for article kind') if article_id.blank?
    end
  end
end
