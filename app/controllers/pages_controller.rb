class PagesController < WebController
  layout :determine_layout
  before_action :authenticate_user!, only: [:profile]

  def home
    @current_day = Day.visible_now.order(number: :desc).first
    @expired_days = Day.where('expires_at <= ?', Time.current).order(number: :desc)
  end

  def about
  end

  def plug
  end

  def profile
    @user = current_user
    @completed_achievements = @user.completed_achievements
    @in_progress_achievements = @user.in_progress_achievements
  end

private

  def determine_layout
    if action_name == 'plug'
      'plug'
    else
      'application'
    end
  end

  def authenticate_user!
    unless current_user&.email_verified?
      redirect_to auth_path, alert: t('auth.flashes.login_required', default: 'Требуется вход в систему')
    end
  end
end
