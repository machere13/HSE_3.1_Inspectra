class Api::V1::InteractivePropsController < ApplicationController
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

  def spy
    serve_interactive_token('dev_diving.network_spy')
  end

  def echo
    serve_interactive_token('legacy.echo_of_past')
  end

  def race_fast
    serve_interactive_token('it_errors.data_race')
  end

  def race_slow
    sleep(2)
    render_success(data: { token: 'SLOW-DECOY' })
  end

  def ie6_token
    interactive, attempt = locate_session_or_render!('legacy.ie6_hack')
    return unless interactive

    ua = request.user_agent.to_s
    if ua.match?(/MSIE 6\.0/i)
      render_success(data: { token: interactive.issue_token_for(current_user), ua: ua })
    else
      render_error(
        code: ERROR_CODES[:validation_error],
        message: 'Доступно только для IE6. Подмени User-Agent в DevTools → Network conditions.',
        status: :forbidden
      )
    end
  end

  def unsecured_profile
    if params[:id].to_i == 1
      interactive, _attempt = locate_session_or_render!('it_security.unsecured_keys')
      return unless interactive
      render_success(data: { user: { id: 1, role: 'admin' }, admin_token: interactive.issue_token_for(current_user) })
    else
      render_success(data: { user: { id: params[:id].to_i, role: 'user' } })
    end
  end

  private

  def serve_interactive_token(interactive_key)
    interactive, _attempt = locate_session_or_render!(interactive_key)
    return unless interactive
    render_success(data: { token: interactive.issue_token_for(current_user) })
  end

  def locate_session_or_render!(interactive_key)
    interactive = Interactive.find_by(key: interactive_key)
    unless interactive
      render_not_found(message: 'interactive not found')
      return [nil, nil]
    end

    attempt = current_user.interactive_attempts.find_by(interactive: interactive)
    submitted = params[:session].to_s

    if attempt.nil? || !attempt.session_valid?(submitted)
      render_error(
        code: ERROR_CODES[:validation_error],
        message: 'Сессия интерактива истекла или не открыта. Перейди на страницу интерактива заново.',
        status: :forbidden
      )
      return [nil, nil]
    end

    if InteractiveCompletion.exists?(user_id: current_user.id, interactive_key: interactive_key, completed_at: ..Time.current)
      render_error(
        code: ERROR_CODES[:validation_error],
        message: 'Этот интерактив уже пройден — токен больше не выдаётся.',
        status: :forbidden
      )
      return [nil, nil]
    end

    [interactive, attempt]
  end
end
