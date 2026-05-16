class InteractiveAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :interactive

  validates :user_id, uniqueness: { scope: :interactive_id }

  def locked?
    locked_until.present? && locked_until > Time.current
  end

  def attempts_left(max_attempts)
    return nil unless max_attempts
    [max_attempts.to_i - count.to_i, 0].max
  end

  def register_fail!(max_attempts: nil, lock_minutes: 60)
    increment!(:count)
    update!(last_attempt_at: Time.current)
    if max_attempts.present? && count >= max_attempts.to_i
      update!(locked_until: lock_minutes.minutes.from_now)
    end
  end
end
