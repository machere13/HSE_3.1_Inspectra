class WeeksController < WebController
  def show
    id = params[:id].to_s
    @week = Week.find_by(number: id.to_i) || Week.find_by(number: id) || Week.find_by(id: id)
    return head :not_found unless @week
    return head :not_found unless @week.visible_now?
    @content_items = @week.content_items.order(:position, :id)
    @content_counts = @week.content_items.group(:kind).count
    track_view!
  end

  private

  def track_view!
    return unless current_user&.email_verified?
    result = ContentViewTracker.new(current_user).track!
    return unless result&.xp_awarded&.positive?

    parts = [t('pages.content_view.xp_awarded', xp: result.xp_awarded, streak: result.new_streak)]
    Array(result.new_titles).each do |title|
      parts << t('pages.profile.titles.earned_toast', title: title.name)
    end
    flash.now[:notice] = parts.join(' · ')
  end

  public

  def og
    id = params[:id].to_s
    week = Week.find_by(number: id.to_i) || Week.find_by(number: id) || Week.find_by(id: id)
    return head :not_found unless week

    begin
      if !week.og_image.attached? || params[:refresh].to_s == '1'
        WeekOgImageService.call!(week)
      end

      return send_data week.og_image.download, type: 'image/png', disposition: 'inline' if week.og_image.attached?
    rescue StandardError => e
      Rails.logger.error({ og_image_error: e.class.name, message: e.message }.to_json)
    end

    fallback = Rails.root.join('app/assets/images/opengraphs/og.png')
    if File.exist?(fallback)
      send_file fallback, type: 'image/png', disposition: 'inline'
    else
      head :not_found
    end
  end
end

