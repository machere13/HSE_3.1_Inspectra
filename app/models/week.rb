class Week < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :content_items, dependent: :destroy

  validates :number, presence: true, uniqueness: true, inclusion: { in: 1..24 }
  validates :title, presence: true

  scope :visible_now, -> { where('published_at <= ? AND expires_at > ?', Time.current, Time.current) }

  def visible_now?
    published_at <= Time.current && expires_at > Time.current
  end

  def expired?
    Time.current >= expires_at
  end

  def time_left
    return '00:00:00' unless expires_at

    remaining = [expires_at - Time.zone.now, 0].max.to_i
    hours = remaining / 1.hour
    minutes = (remaining % 1.hour) / 1.minute
    seconds = remaining % 1.minute
    format('%02d:%02d:%02d', hours, minutes, seconds)
  end

  def to_param
    number.to_s
  end

  before_validation :apply_default_visibility_window, on: [:create]
  after_create :create_next_week_if_needed

  private

  def apply_default_visibility_window
    return if published_at.present? && expires_at.present?

    if number == 1
      start_date = Rails.configuration.x.schedule.start_date
      switch_hour = Rails.configuration.x.schedule.switch_hour
      base_start = Time.zone.local(start_date.year, start_date.month, start_date.day, switch_hour, 0)
    else
      previous_week = Week.find_by(number: number - 1)
      if previous_week&.expires_at
        base_start = previous_week.expires_at
      else
        start_date = Rails.configuration.x.schedule.start_date
        switch_hour = Rails.configuration.x.schedule.switch_hour
        base_start = Time.zone.local(start_date.year, start_date.month, start_date.day, switch_hour, 0) + (number.to_i - 1).weeks
      end
    end

    self.published_at ||= base_start
    self.expires_at   ||= base_start + AppConfig::Content.week_expiration_hours
  end

  def create_next_week_if_needed
    next_number = number + 1
    return if next_number > 24
    return if Week.exists?(number: next_number)

    begin
      Week.create!(
        number: next_number,
        title: "Неделя #{next_number}",
        description: nil,
        published_at: expires_at,
        expires_at: expires_at + AppConfig::Content.week_expiration_hours
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create next week #{next_number}: #{e.message}"
    end
  end
end

