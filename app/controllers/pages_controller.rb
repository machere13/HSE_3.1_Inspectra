class PagesController < WebController
  layout :determine_layout
  before_action :authenticate_user!, only: [:profile, :select_title, :update_name, :update_avatar, :request_password_change]

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
    @reset_token = params[:token]
    if @reset_token.present? && @user.reset_password_token == @reset_token
      @show_reset_form = @user.reset_token_valid?
    end
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

  def update_avatar
    @user = current_user
    avatar_param = params[:avatar] || params.dig(:user, :avatar)
    if avatar_param.present?
      @user.avatar.attach(avatar_param)
      if @user.avatar.attached?
        Rails.logger.info "Avatar attached successfully: #{@user.avatar.blob.filename}, URL: #{url_for(@user.avatar)}"
        redirect_to profile_path, notice: t('pages.profile.avatar.updated')
      else
        Rails.logger.error "Failed to attach avatar"
        redirect_to profile_path, alert: 'Ошибка при загрузке аватара'
      end
    else
      Rails.logger.error "Avatar param missing. Params: #{params.keys.inspect}"
      redirect_to profile_path, alert: t('pages.profile.avatar.required')
    end
  end

  def update_password
    @user = current_user
    current_password = params[:current_password]
    new_password = params[:password]
    password_confirmation = params[:password_confirmation]

    if current_password.blank? || new_password.blank? || password_confirmation.blank?
      redirect_to profile_path, alert: t('pages.profile.password_change.all_fields_required')
      return
    end

    unless @user.authenticate(current_password)
      redirect_to profile_path, alert: t('pages.profile.password_change.wrong_current_password')
      return
    end

    if new_password.length < AppConfig::Auth.password_min_length || new_password.length > AppConfig::Auth.password_max_length
      redirect_to profile_path, alert: t('auth.flashes.password_length_invalid')
      return
    end

    @user.password = new_password
    @user.password_confirmation = password_confirmation
    if @user.save
      redirect_to profile_path, notice: t('pages.profile.password_change.success')
    else
      redirect_to profile_path, alert: @user.errors.full_messages.join(', ')
    end
  end

  def request_password_change
    @user = current_user
    if @user.reset_password_requested_at && @user.reset_password_requested_at > AppConfig::Auth.resend_code_cooldown_seconds.ago
      redirect_to profile_path, alert: t('auth.flashes.email_already_sent_try_later')
      return
    end

    begin
      @user.generate_reset_password_token!
      ResetPasswordMailer.with(user: @user).reset_instructions.deliver_now
      redirect_to profile_path, notice: t('pages.profile.password_change.email_sent')
    rescue => e
      Rails.logger.error "Failed to send password reset email: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to profile_path, alert: "Ошибка при отправке письма: #{e.message}"
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
