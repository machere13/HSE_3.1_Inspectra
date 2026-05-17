class LegacyIframesController < ActionController::Base
  include ActionController::Cookies
  include JwtHelper

  layout false

  before_action :authenticate_via_cookie!

  def show
    @interactive = Interactive.find_by(key: 'legacy.ancient_iframe')
    @variant = @interactive&.interactive_variants&.find_by(seed: params[:seed].to_i)
    return head :not_found unless @variant

    return head :forbidden unless valid_session?(@interactive)

    @answer_token = @interactive.issue_token_for(current_user, variant: @variant)
    render :show
  end

  def archive
    @interactive = Interactive.find_by(key: 'legacy.archive_worm')
    @variant = @interactive&.interactive_variants&.find_by(seed: params[:seed].to_i)
    return head :not_found unless @variant

    return head :forbidden unless valid_session?(@interactive)

    @answer_token = @interactive.issue_token_for(current_user, variant: @variant)
    render :archive
  end

  private

  def authenticate_via_cookie!
    token = cookies[:token].presence
    decoded = token && decode_token(token)
    @current_user = decoded && User.find_by(id: decoded['user_id'])
    head :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def valid_session?(interactive)
    return false unless interactive
    attempt = current_user.interactive_attempts.find_by(interactive: interactive)
    submitted = params[:session].to_s
    return false unless attempt&.session_valid?(submitted)
    !InteractiveCompletion.exists?(user_id: current_user.id, interactive_key: interactive.key, completed_at: ..Time.current)
  end
end
