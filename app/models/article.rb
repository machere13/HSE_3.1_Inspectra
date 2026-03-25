class Article < ApplicationRecord
  belongs_to :week
  has_many :content_items, dependent: :nullify
  has_one_attached :cover_image

  validates :title, presence: true
  validates :body, presence: true

  before_validation :normalize_tags

  def tag_list
    Array(tags).join(', ')
  end

  def tag_list=(value)
    self.tags = self.class.parse_tags(value)
  end

  def self.parse_tags(value)
    value.to_s
      .split(',')
      .map { |item| item.strip.downcase }
      .reject(&:blank?)
      .uniq
  end

  private

  def normalize_tags
    self.tags = self.class.parse_tags(Array(tags).join(','))
  end
end
