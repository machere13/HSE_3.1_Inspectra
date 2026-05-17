class ContentViewTracker
  XP_PER_DAY = 20

  Result = Struct.new(:new_streak, :xp_awarded, :new_titles, keyword_init: true)

  def initialize(user)
    @user = user
  end

  def track!(now: Time.current)
    return nil unless @user

    new_streak = @user.register_content_view!(now: now)

    if new_streak.nil?
      # Уже сегодня смотрел — ничего не начисляем.
      return Result.new(new_streak: nil, xp_awarded: 0, new_titles: [])
    end

    @user.add_experience!(XP_PER_DAY)

    achievement_service = AchievementService.new(@user)
    achievement_service.check_achievements_for_consecutive_days(new_streak)

    PlatformLifetimeService.new(@user, achievement_service: achievement_service).check!(now: now)

    Result.new(
      new_streak: new_streak,
      xp_awarded: XP_PER_DAY,
      new_titles: achievement_service.newly_awarded_titles
    )
  end
end
