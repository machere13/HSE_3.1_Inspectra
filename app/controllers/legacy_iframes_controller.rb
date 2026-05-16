class LegacyIframesController < ApplicationController
  layout false

  # GET /legacy/iframes/:seed
  def show
    interactive = Interactive.find_by(key: 'legacy.ancient_iframe')
    @variant = interactive&.interactive_variants&.find_by(seed: params[:seed].to_i)
    return head :not_found unless @variant

    render :show
  end

  # GET /legacy/archives/:seed
  # Для "Архивный червь" — устаревшая страница с ответом.
  def archive
    interactive = Interactive.find_by(key: 'legacy.archive_worm')
    @variant = interactive&.interactive_variants&.find_by(seed: params[:seed].to_i)
    return head :not_found unless @variant

    render :archive
  end
end
