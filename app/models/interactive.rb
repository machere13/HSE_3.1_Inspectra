class Interactive < ApplicationRecord
  has_many :interactive_variants, dependent: :destroy
  has_many :completions, class_name: 'InteractiveCompletion', dependent: :destroy
  belongs_to :article, optional: true

  KINDS = %w[
    find_text_in_html
    inspect_devtools
    console_input
    user_agent_swap
    iframe_hunt
    sandbox_code_fix
    phishing_quiz
    password_crack
    xss_payload
  ].freeze

  CATEGORIES = %w[dev_diving legacy it_errors it_security].freeze

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :xp_reward, numericality: { greater_than_or_equal_to: 0 }

  scope :by_category, ->(c) { where(category: c) }

  def variant_for(user)
    list = interactive_variants.order(:seed).to_a
    return nil if list.empty?
    idx = user.id.to_i % list.size
    list[idx]
  end
end
