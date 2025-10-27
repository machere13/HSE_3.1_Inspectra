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

  before_validation :apply_default_visibility_window, on: [:create]

  private

  def apply_default_visibility_window
    return if published_at.present? && expires_at.present?

    start_date = Rails.configuration.x.schedule.start_date
    switch_hour = Rails.configuration.x.schedule.switch_hour

    base_start = Time.zone.local(start_date.year, start_date.month, start_date.day, switch_hour, 0) + (number.to_i - 1).days
    self.published_at ||= base_start
    self.expires_at   ||= base_start + 24.hours
  end
end
