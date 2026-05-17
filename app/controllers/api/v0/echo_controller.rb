class Api::V0::EchoController < ApplicationController
  include ActionController::Cookies
  include JwtHelper

  before_action :require_auth

  def current_user
    token = token_from_header.presence || cookies[:token].presence
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find(decoded_token['user_id'])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def show
    interactive = Interactive.find_by(key: 'legacy.echo_of_past')
    return render_not_found(message: 'echo not found') unless interactive

    attempt = current_user.interactive_attempts.find_by(interactive: interactive)
    submitted = params[:session].to_s

    unless attempt && attempt.session_valid?(submitted)
      render_error(
        code: ERROR_CODES[:validation_error],
        message: 'Сессия интерактива истекла. Открой интерактив заново.',
        status: :forbidden
      )
      return
    end

    if InteractiveCompletion.exists?(user_id: current_user.id, interactive_key: interactive.key, completed_at: ..Time.current)
      render_error(
        code: ERROR_CODES[:validation_error],
        message: 'Этот интерактив уже пройден.',
        status: :forbidden
      )
      return
    end

    render_success(data: { token: interactive.issue_token_for(current_user), deprecated: true })
  end
end
