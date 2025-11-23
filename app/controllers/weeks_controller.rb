class WeeksController < WebController
  def show
    id = params[:id].to_s
    @week = Week.find_by(number: id.to_i) || Week.find_by(number: id) || Week.find_by(id: id)
    return head :not_found unless @week
    return head :not_found unless @week.visible_now?
    @content_items = @week.content_items.order(:position, :id)
    @content_counts = @week.content_items.group(:kind).count
  end
end

