class Admin::BaseController < WebController
  include JwtHelper
  include CanCan::ControllerAdditions

  layout 'admin'

  before_action :authenticate_user!
  before_action :authorize_admin_panel

  helper_method :current_user

  private

  def current_user
    token = cookies[:token].presence || token_from_header
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find_by(id: decoded_token['user_id'])
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def authenticate_user!
    unless current_user&.email_verified?
      redirect_to auth_path, alert: t('auth.flashes.login_required', default: 'Требуется вход в систему')
    end
  end

  def authorize_admin_panel
    authorize! :read, :admin_panel
  rescue CanCan::AccessDenied
    redirect_to auth_path, alert: t('auth.flashes.login_required', default: 'Требуется вход в систему')
  end
end


