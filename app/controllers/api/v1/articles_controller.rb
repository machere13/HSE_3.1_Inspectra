class Api::V1::ArticlesController < ApplicationController
  def index
    @week = Week.find(params[:week_id])
    @pagy, @articles = pagy(@week.articles.order(:created_at))
    render_success(data: @articles, pagy: @pagy)
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Неделя не найдена')
  end

  def show
    @week = Week.find(params[:week_id])
    @article = @week.articles.find(params[:id])
    render_success(data: @article)
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Статья не найдена')
  end
end
