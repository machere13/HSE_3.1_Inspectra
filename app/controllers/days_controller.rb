class DaysController < WebController
  def show
    id = params[:id].to_s
    @day = Day.find_by(number: id.to_i) || Day.find_by(number: id) || Day.find_by(id: id)
    return head :not_found unless @day
    return head :not_found unless @day.visible_now?
    @content_items = @day.content_items.order(:position, :id)
    @content_counts = @day.content_items.group(:kind).count
  end
end
