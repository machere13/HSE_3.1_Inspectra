class WeeksController < WebController
  def show
    id = params[:id].to_s
    @week = Week.find_by(number: id.to_i) || Week.find_by(number: id) || Week.find_by(id: id)
    return head :not_found unless @week
    return head :not_found unless @week.visible_now?
    @content_items = @week.content_items.order(:position, :id)
    @content_counts = @week.content_items.group(:kind).count
  end

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

