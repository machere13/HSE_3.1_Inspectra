class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements
  belongs_to :title, optional: true

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validates :progress_type, presence: true
  validates :progress_target, presence: true, numericality: { greater_than: 0 }
  
  enum :progress_type, {
    consecutive_days: 'consecutive_days',
    total_interactives: 'total_interactives',
    registration_order: 'registration_order',
    platform_lifetime: 'platform_lifetime'
  }
  
  enum :category, {
    registration: 'registration',
    content_viewing: 'content_viewing',
    dev_diving: 'dev_diving',
    legacy: 'legacy',
    it_errors: 'it_errors',
    it_security: 'it_security',
    general: 'general'
  }
end
