class ArticlesController < WebController
  def show
    wid = params[:week_id].to_s
    @week = Week.find_by(number: wid.to_i) || Week.find_by(number: wid) || Week.find_by(id: wid)
    return head :not_found unless @week
    @article = @week.articles.find(params[:id])
  end
end
