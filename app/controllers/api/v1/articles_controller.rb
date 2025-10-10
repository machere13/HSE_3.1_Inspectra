class Api::V1::ArticlesController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @articles = @day.articles
    render json: @articles
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'День не найден' }, status: :not_found
  end

  def show
    @day = Day.find(params[:day_id])
    @article = @day.articles.find(params[:id])
    render json: @article
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Статья не найдена' }, status: :not_found
  end
end
