class DevController < WebController
  include JwtHelper

  def make_me_admin
    unless Rails.env.development?
      return render plain: 'Not allowed', status: :forbidden
    end

    user = current_user
    unless user
      redirect_to auth_path, alert: 'Сначала войдите'
      return
    end

    user.update!(admin: true, email_verified: true)
    redirect_to '/admin', notice: 'Вы стали админом'
  end

  private

  def current_user
    token = cookies[:token].presence || token_from_header
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find_by(id: decoded_token['user_id'])
  end
end


