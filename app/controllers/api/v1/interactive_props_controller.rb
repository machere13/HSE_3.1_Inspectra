class Api::V1::InteractivePropsController < ApplicationController
  include JwtHelper

  before_action :require_auth

  # Эндпоинты вызываются fetch'ем со страницы интерактива.
  # Браузер автоматически шлёт httponly cookie :token; JS прочитать его не может,
  # поэтому header может быть пуст. Читаем токен из куки как fallback.
  def current_user
    token = token_from_header.presence || cookies[:token].presence
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find(decoded_token['user_id'])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  # GET /api/v1/interactive_props/spy?seed=N
  # Используется в "Сетевой шпион". Юзер должен найти ответ в DevTools->Network.
  def spy
    variant = find_variant!('dev_diving.network_spy', params[:seed])
    return render_not_found(message: 'variant not found') unless variant
    render_success(data: { token: variant.payload['token'] || variant.expected_answer })
  end

  # GET /api/v1/interactive_props/echo?seed=N — версия V1 (для "Эхо прошлого" V0 ниже).
  def echo
    variant = find_variant!('legacy.echo_of_past', params[:seed])
    return render_not_found(message: 'variant not found') unless variant
    render_success(data: { token: variant.expected_answer })
  end

  # GET /api/v1/interactive_props/race/fast?seed=N
  def race_fast
    variant = find_variant!('it_errors.data_race', params[:seed])
    return render_not_found(message: 'variant not found') unless variant
    render_success(data: { token: variant.expected_answer })
  end

  # GET /api/v1/interactive_props/race/slow?seed=N
  def race_slow
    sleep(2)
    render_success(data: { token: 'SLOW-DECOY' })
  end

  # GET /api/v1/interactive_props/ie6_token?seed=N
  # Возвращает токен только если User-Agent действительно от старого IE.
  def ie6_token
    variant = find_variant!('legacy.ie6_hack', params[:seed])
    return render_not_found(message: 'variant not found') unless variant

    ua = request.user_agent.to_s
    is_ie6 = ua.match?(/MSIE 6\.0/i)

    if is_ie6
      render_success(data: { token: variant.expected_answer, ua: ua })
    else
      render_error(
        code: ERROR_CODES[:validation_error],
        message: 'Доступно только для IE6. Подмени User-Agent в DevTools -> Network conditions.',
        status: :forbidden
      )
    end
  end

  # GET /api/v1/interactive_props/profile/:id?seed=N
  # IDOR-имитация: id=1 возвращает админский токен.
  def unsecured_profile
    if params[:id].to_i == 1
      variant = find_variant!('it_security.unsecured_keys', params[:seed])
      return render_not_found(message: 'variant not found') unless variant
      render_success(data: { user: { id: 1, role: 'admin' }, admin_token: variant.expected_answer })
    else
      render_success(data: { user: { id: params[:id].to_i, role: 'user' } })
    end
  end

  private

  def find_variant!(interactive_key, seed_param)
    interactive = Interactive.find_by(key: interactive_key)
    return nil unless interactive
    interactive.interactive_variants.find_by(seed: seed_param.to_i)
  end
end
