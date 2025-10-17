class User < ApplicationRecord
  has_secure_password
  
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :password, length: { maximum: 64 }, allow_nil: true
  
  after_create :check_registration_achievements
  
  def generate_verification_code!
    self.verification_code = SecureRandom.random_number(1000000).to_s.rjust(6, '0')
    self.verification_code_expires_at = 15.minutes.from_now
    save!
  end
  
  def verification_code_valid?(code)
    verification_code == code && 
    verification_code_expires_at.present? && 
    verification_code_expires_at > Time.current
  end
  
  def verify_email!
    update!(email_verified: true, verification_code: nil, verification_code_expires_at: nil)
  end
  
  def email_verification_required?
    !email_verified?
  end
  
  def completed_achievements
    user_achievements.completed.includes(:achievement)
  end
  
  def in_progress_achievements
    user_achievements.in_progress.includes(:achievement)
  end
  
  def achievement_progress(achievement)
    user_achievements.find_by(achievement: achievement)&.progress || 0
  end
  
  def has_achievement?(achievement)
    user_achievements.exists?(achievement: achievement, completed_at: ..Time.current)
  end
  
  private
  
  def check_registration_achievements
    AchievementService.new(self).check_achievements_for_registration_order
  end

  public

  def generate_reset_password_token!
    update!(
      reset_password_token: SecureRandom.urlsafe_base64(32),
      reset_password_sent_at: Time.current,
      reset_password_requested_at: Time.current
    )
  end

  def clear_reset_password_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end

  def reset_token_valid?(ttl_minutes: 30)
    reset_password_token.present? && reset_password_sent_at.present? && reset_password_sent_at > ttl_minutes.minutes.ago
  end
end
