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
end
