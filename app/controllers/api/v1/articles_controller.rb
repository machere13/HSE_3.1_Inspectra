class Api::V1::ArticlesController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @pagy, @articles = pagy(@day.articles.order(:created_at))
    render_success(data: @articles, pagy: @pagy)
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
