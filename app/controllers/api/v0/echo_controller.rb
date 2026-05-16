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
    variant = interactive&.interactive_variants&.find_by(seed: params[:seed].to_i)

    if variant
      render_success(data: { token: variant.expected_answer, deprecated: true })
    else
      render_not_found(message: 'echo not found')
    end
  end
end
