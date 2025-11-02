class ApplicationController < ActionController::API
  include ApiResponseFormatter

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_not_found(message: 'Ресурс не найден')
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render_validation_error(message: "Отсутствует обязательный параметр: #{exception.param}")
  end
end
