module ApiResponseFormatter
  extend ActiveSupport::Concern

  ERROR_CODES = {
    validation_error: 'VALIDATION_ERROR',
    authentication_required: 'AUTHENTICATION_REQUIRED',
    authentication_failed: 'AUTHENTICATION_FAILED',
    not_found: 'NOT_FOUND',
    unauthorized: 'UNAUTHORIZED',
    forbidden: 'FORBIDDEN',
    too_many_requests: 'TOO_MANY_REQUESTS',
    internal_error: 'INTERNAL_ERROR'
  }.freeze

  protected

  def render_success(data: nil, message: nil, status: :ok)
    response = { success: true }
    response[:data] = data if data
    response[:message] = message if message
    render json: response, status: status
  end

  def render_error(code:, message:, details: nil, status: :bad_request)
    response = {
      success: false,
      error: {
        code: code,
        message: message
      }
    }
    response[:error][:details] = details if details
    render json: response, status: status
  end

  def render_validation_error(message:, details: nil)
    render_error(
      code: ERROR_CODES[:validation_error],
      message: message,
      details: details,
      status: :bad_request
    )
  end

  def render_authentication_required
    render_error(
      code: ERROR_CODES[:authentication_required],
      message: 'Требуется авторизация',
      status: :unauthorized
    )
  end

  def render_not_found(message: 'Ресурс не найден')
    render_error(
      code: ERROR_CODES[:not_found],
      message: message,
      status: :not_found
    )
  end

  def render_unauthorized(message: 'Неверные учетные данные')
    render_error(
      code: ERROR_CODES[:unauthorized],
      message: message,
      status: :unauthorized
    )
  end

  def render_too_many_requests(message: 'Слишком много запросов')
    render_error(
      code: ERROR_CODES[:too_many_requests],
      message: message,
      status: :too_many_requests
    )
  end
end
