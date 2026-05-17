class InteractiveSession
  Result = Struct.new(:success?, :completion, :variant, :error_message, :locked, :new_titles, keyword_init: true)

  LOCK_MINUTES = 60

  def initialize(user:, interactive:)
    @user = user
    @interactive = interactive
  end

  def variant
    @variant ||= persisted_variant || @interactive.variant_for(@user)
  end

  def already_completed?
    InteractiveCompletion.exists?(
      user_id: @user.id,
      interactive_key: @interactive.key,
      completed_at: ..Time.current
    )
  end

  def attempts_record
    @attempts_record ||= @user.interactive_attempts.find_or_create_by!(interactive: @interactive)
  end

  def max_attempts
    base = variant&.payload&.dig('max_attempts')
    return nil unless base
    base = base.to_i
    base += 1 if warrior_bonus_applies?
    base
  end

  def warrior_bonus_applies?
    @user&.game_role_warrior? && @interactive&.category == 'it_errors'
  end

  def attempts_left
    attempts_record.attempts_left(max_attempts)
  end

  def locked?
    attempts_record.locked?
  end

  def submit(answer)
    v = variant
    return Result.new(success?: false, error_message: I18n.t('pages.interactive.no_variant')) unless v

    if already_completed?
      return Result.new(success?: false, variant: v, error_message: I18n.t('pages.interactive.already_completed'))
    end

    if locked?
      return Result.new(success?: false, variant: v, locked: true, error_message: I18n.t('pages.interactive.locked'))
    end

    unless matches_answer?(answer, v)
      attempts_record.register_fail!(max_attempts: max_attempts, lock_minutes: LOCK_MINUTES)
      msg = max_attempts ? I18n.t('pages.interactive.wrong_with_attempts', left: attempts_left) : I18n.t('pages.interactive.wrong_answer')
      return Result.new(success?: false, variant: v, locked: locked?, error_message: msg)
    end

    service = InteractiveCompletionService.new(user: @user, interactive: @interactive, variant: v)
    completion = service.complete!

    Result.new(success?: true, completion: completion, variant: v, new_titles: service.new_titles || [])
  end

  private

  def matches_answer?(answer, v)
    if @interactive.randomizable?
      expected = @interactive.issue_token_for(@user, variant: v)
      ActiveSupport::SecurityUtils.secure_compare(
        answer.to_s.strip.downcase,
        expected.to_s.strip.downcase
      )
    else
      v.matches?(answer, kind: @interactive.kind)
    end
  end

  def persisted_variant
    completion = InteractiveCompletion.find_by(user_id: @user.id, interactive_key: @interactive.key)
    return nil unless completion
    completion.interactive_variant
  end
end
