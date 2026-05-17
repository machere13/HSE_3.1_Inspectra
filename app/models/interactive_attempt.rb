class InteractiveAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :interactive

  SESSION_TTL = 30.minutes

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

  def issue_session!
    token = SecureRandom.hex(16)
    update!(session_token: token, session_expires_at: SESSION_TTL.from_now)
    token
  end

  def session_valid?(submitted_token)
    return false if submitted_token.blank?
    return false if session_token.blank?
    return false if session_expires_at.blank? || session_expires_at < Time.current
    ActiveSupport::SecurityUtils.secure_compare(session_token.to_s, submitted_token.to_s)
  end

  def clear_session!
    update!(session_token: nil, session_expires_at: nil)
  end
end
