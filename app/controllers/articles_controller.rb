class ArticlesController < WebController
  def show
    @day = Day.find_by(number: params[:day_id]) || Day.find(params[:day_id])
    @article = @day.articles.find(params[:id])
  end
end
