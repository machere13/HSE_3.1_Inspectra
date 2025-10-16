class Day < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :content_items, dependent: :destroy

  validates :number, presence: true, uniqueness: true, inclusion: { in: 1..15 }
  validates :title, presence: true

  scope :visible_now, -> { where('published_at <= ? AND expires_at > ?', Time.current, Time.current) }

  def visible_now?
    published_at <= Time.current && expires_at > Time.current
  end

  def expired?
    Time.current >= expires_at
  end

  def to_param
    number.to_s
  end
end
