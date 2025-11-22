class WebController < ActionController::Base
  include Pagy::Backend
  include JwtHelper
  
  layout "application"
  
  helper ContentItemHelper
  helper_method :current_user
  
  rescue_from Pagy::OverflowError do |exception|
    redirect_to request.path, alert: "Страница #{params[:page]} не существует"
  end
  
  private
  
  def current_user
    token = cookies[:token].presence || token_from_header
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find_by(id: decoded_token['user_id'])
  rescue ActiveRecord::RecordNotFound
    nil
  end
end