class Api::V1::ArticlesController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @articles = @day.articles
    render_success(data: @articles)
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'День не найден')
  end

  def show
    @day = Day.find(params[:day_id])
    @article = @day.articles.find(params[:id])
    render_success(data: @article)
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Статья не найдена')
  end
end
