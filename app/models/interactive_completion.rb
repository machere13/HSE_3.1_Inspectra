class InteractiveCompletion < ApplicationRecord
  belongs_to :user
  belongs_to :article, optional: true
  belongs_to :interactive, optional: true
  belongs_to :interactive_variant, optional: true

  validates :interactive_key, presence: true
  validates :category, presence: true
  validates :completed_at, presence: true

  scope :for_category, ->(c) { where(category: c) }
end
