class Api::V1::ArticlesController < ApplicationController
  def index
    @week = find_week_by_param(params[:week_id])
    @pagy, @articles = pagy(@week.articles.order(:created_at))
    render_success(data: @articles, pagy: @pagy)
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Неделя не найдена')
  end

  def show
    @week = find_week_by_param(params[:week_id])
    @article = @week.articles.find(params[:id])
    render_success(data: @article)
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Статья не найдена')
  end

  private

  def find_week_by_param(param)
    Week.visible_now.find_by(number: param) || Week.visible_now.find_by(id: param) || (raise ActiveRecord::RecordNotFound)
  end
end
