class PagesController < WebController
  layout :determine_layout
  before_action :authenticate_user!, only: [:profile, :select_title, :update_name]

  def home
    @current_week = Week.visible_now.order(number: :desc).first
    @expired_weeks = Week.where('expires_at <= ?', Time.current).order(number: :desc)
  end

  def about
  end

  def plug
  end

  def profile
    @user = current_user
    @completed_achievements = @user.completed_achievements
    @in_progress_achievements = @user.in_progress_achievements
    @available_titles = @user.available_titles
  end
  
  def select_title
    @user = current_user
    title = Title.find(params[:title_id])
    
    begin
      @user.select_title!(title)
      redirect_to profile_path, notice: t('pages.profile.title_selected', title: title.name)
    rescue ArgumentError
      redirect_to profile_path, alert: t('pages.profile.title_not_available')
    end
  end

  def update_name
    @user = current_user
    if @user.update(name: params[:name])
      redirect_to profile_path, notice: t('pages.profile.name_updated')
    else
      redirect_to profile_path, alert: @user.errors.full_messages.join(', ')
    end
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
