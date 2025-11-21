class WebController < ActionController::Base
  include Pagy::Backend
  
  layout "application"
  
  helper ContentItemHelper
  
  rescue_from Pagy::OverflowError do |exception|
    redirect_to request.path, alert: "Страница #{params[:page]} не существует"
  end
end