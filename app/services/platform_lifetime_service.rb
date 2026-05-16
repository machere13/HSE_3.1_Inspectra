class PlatformLifetimeService
  TOGETHER_FROM_START = 'Вместе от начала до конца'.freeze
  LAST_WITNESS = 'Последний свидетель'.freeze

  def initialize(user, achievement_service: nil)
    @user = user
    @achievement_service = achievement_service || AchievementService.new(user)
  end

  def check!(now: Time.current)
    return unless @user

    check_together_from_start(now)
    check_last_witness(now)
  end

  private

  def check_together_from_start(now)
    return if @user.platform_lifetime_marked_at.present?

    start_date = AppConfig::Platform.start_date
    end_date = AppConfig::Platform.end_date

    return unless start_date && end_date
    return unless @user.created_at.to_date <= start_date.to_date
    return unless now >= end_date

    achievement = Achievement.find_by(name: TOGETHER_FROM_START)
    return unless achievement

    @achievement_service.check_achievements_for_platform_lifetime
    @user.update_column(:platform_lifetime_marked_at, now)
  end

  def check_last_witness(now)
    return if @user.last_day_witnessed_at.present?

    end_date = AppConfig::Platform.end_date
    return unless end_date
    return unless now.to_date == end_date.to_date

    achievement = Achievement.find_by(name: LAST_WITNESS)
    return unless achievement

    user_achievement = @user.user_achievements.find_or_create_by(achievement: achievement) do |ua|
      ua.progress = 0
    end
    return if user_achievement.completed?

    user_achievement.update!(progress: 1, completed_at: now)
    @achievement_service.award_title(achievement)
    @user.update_column(:last_day_witnessed_at, now)
  end
end
