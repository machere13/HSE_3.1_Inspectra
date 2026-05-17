class InteractiveCompletionService
  ROLE_SPECIALTY_BONUS = 0.15

  def initialize(user:, interactive:, variant:)
    @user = user
    @interactive = interactive
    @variant = variant
  end

  attr_reader :new_titles

  def complete!
    completion = nil
    @new_titles = []

    InteractiveCompletion.transaction do
      completion = InteractiveCompletion.create!(
        user: @user,
        interactive: @interactive,
        interactive_variant: @variant,
        interactive_key: @interactive.key,
        category: @interactive.category,
        completed_at: Time.current,
        metadata: {
          variant_seed: @variant.seed,
          xp_awarded: total_xp
        }
      )

      @user.add_experience!(total_xp)
      svc = AchievementService.new(@user)
      svc.check_achievements_for_interactive_completion(@interactive.category)
      @new_titles = svc.newly_awarded_titles

      attempt = @user.interactive_attempts.find_by(interactive: @interactive)
      attempt&.clear_session!
    end

    completion
  end

  private

  def total_xp
    base = @interactive.xp_reward.to_i
    base += (base * ROLE_SPECIALTY_BONUS).round if specialty_bonus?
    base
  end

  def specialty_bonus?
    @user.specialty_category.present? && @user.specialty_category == @interactive.category
  end
end
