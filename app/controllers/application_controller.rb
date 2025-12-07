class ApplicationController < ActionController::API
  include ApiResponseFormatter
  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_not_found(message: 'Ресурс не найден')
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render_validation_error(message: "Отсутствует обязательный параметр: #{exception.param}")
  end

  rescue_from Pagy::OverflowError do |exception|
    render_validation_error(message: "Страница #{params[:page]} не существует")
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
    
    render_error(
      code: ERROR_CODES[:internal_error],
      message: 'Внутренняя ошибка сервера',
      status: :internal_server_error
    )
  end
end
