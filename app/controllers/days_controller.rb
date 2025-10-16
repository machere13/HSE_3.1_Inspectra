class DaysController < WebController
  def show
    @day = Day.find_by(number: params[:id]) || Day.find(params[:id])
    return head :not_found unless @day.visible_now?
    @content_items = @day.content_items.order(:position, :id)
  end
end
