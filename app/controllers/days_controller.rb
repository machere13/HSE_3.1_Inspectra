class DaysController < WebController
  def show
    @day = Day.find_by(number: params[:id]) || Day.find(params[:id])
    @content_items = @day.content_items.order(:position, :id)
  end
end
