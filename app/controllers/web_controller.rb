class WebController < ActionController::Base
  include Pagy::Backend
  include JwtHelper
  include ErrorsPageRendering

  layout "application"

  helper ContentItemHelper
  helper_method :current_user

  rescue_from CanCan::AccessDenied do
    assign_error_page!(403)
    render 'errors/show', status: :forbidden, layout: 'application'
  end

  rescue_from Pagy::OverflowError do |exception|
    redirect_to request.path, alert: "Страница #{params[:page]} не существует"
  end

  rescue_from StandardError, with: :handle_internal_error

  private

  def handle_internal_error(exception)
    Sentry.capture_exception(exception) if defined?(Sentry)

    Rails.logger.error({
      exception: exception.class.name,
      message: exception.message,
      backtrace: exception.backtrace&.first(10)
    }.to_json)

    assign_error_page!(500)
    render 'errors/show', status: :internal_server_error, layout: 'application'
  rescue ActionView::MissingTemplate
    render plain: 'Внутренняя ошибка сервера', status: :internal_server_error
  end
  
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