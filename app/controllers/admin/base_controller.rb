class Admin::BaseController < WebController
  include JwtHelper

  layout 'admin'

  before_action :require_admin

  helper_method :current_user

  private

  def current_user
    token = cookies[:token].presence || token_from_header
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find_by(id: decoded_token['user_id'])
  end

  def require_admin
    unless current_user&.email_verified? && current_user&.admin?
      redirect_to auth_path, alert: t('auth.flashes.login_required', default: 'Требуется вход в систему')
    end
  end
end


