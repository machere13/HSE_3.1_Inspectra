class ContentItem < ApplicationRecord
  belongs_to :day
  has_one_attached :file

  KINDS = %w[image gif video audio link].freeze

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :day, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :validate_payload

  private

  def validate_payload
    case kind
    when 'image', 'gif', 'video', 'audio'
      if url.blank? && !file.attached?
        errors.add(:base, 'Нужно указать URL или загрузить файл')
      end
    when 'link'
      errors.add(:url, 'URL обязателен для ссылки') if url.blank?
    end
  end
end
