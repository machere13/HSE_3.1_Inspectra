class ArticlesController < WebController
  def show
    did = params[:day_id].to_s
    @day = Day.find_by(number: did.to_i) || Day.find_by(number: did) || Day.find_by(id: did)
    return head :not_found unless @day
    @article = @day.articles.find(params[:id])
  end
end
