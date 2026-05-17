class InteractivesController < WebController
  before_action :authenticate_user!
  before_action :load_interactive

  def index
    @interactives = Interactive.order(:category, :difficulty, :title)
    @completed_keys = current_user.interactive_completions.pluck(:interactive_key).to_set
  end

  def show
    @session = InteractiveSession.new(user: current_user, interactive: @interactive)
    if @session.locked?
      redirect_to interactives_path, alert: t('pages.interactive.locked') and return
    end
    @variant = @session.variant
    @already_completed = @session.already_completed?
    @attempts_left = @session.attempts_left
    @max_attempts = @session.max_attempts

    @session_token = unless @already_completed
      @session.attempts_record.issue_session!
    end
  end

  def submit
    session = InteractiveSession.new(user: current_user, interactive: @interactive)
    result = session.submit(params[:answer])

    if result.success?
      xp = result.completion.metadata['xp_awarded']
      messages = [t('pages.interactive.completed', xp: xp)]
      Array(result.new_titles).each do |title|
        messages << t('pages.profile.titles.earned_toast', title: title.name)
      end
      redirect_to interactive_path(@interactive.key), notice: messages.join(' · ')
    elsif result.locked
      redirect_to interactives_path, alert: result.error_message
    else
      redirect_to interactive_path(@interactive.key), alert: result.error_message
    end
  end

  private

  def load_interactive
    return if action_name == 'index'
    @interactive = Interactive.find_by!(key: params[:key])
  rescue ActiveRecord::RecordNotFound
    redirect_to interactives_path, alert: t('pages.interactive.not_found')
  end

  def authenticate_user!
    unless current_user&.email_verified?
      redirect_to auth_path, alert: t('auth.flashes.login_required', default: 'Требуется вход в систему')
    end
  end
end
