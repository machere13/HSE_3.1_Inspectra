class Level < ApplicationRecord
  validates :number, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validates :required_xp, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true

  scope :ordered, -> { order(:number) }

  def self.for_experience(xp)
    where('required_xp <= ?', xp.to_i).order(required_xp: :desc).first || ordered.first
  end

  def next_level
    self.class.where('number > ?', number).ordered.first
  end

  def xp_to_next_level
    return 0 unless next_level
    next_level.required_xp - required_xp
  end
end
