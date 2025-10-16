class Api::V1::DaysController < ApplicationController
  def index
    @days = Day.visible_now.includes(:articles, :content_items).order(:number)
    render json: @days, include: [:articles, :content_items]
  end

  def show
    @day = Day.visible_now.includes(:articles, :content_items).find_by(number: params[:id]) ||
           Day.visible_now.includes(:articles, :content_items).find_by(id: params[:id]) ||
           (raise ActiveRecord::RecordNotFound)
    render json: @day, include: [:articles, :content_items]
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'День не найден' }, status: :not_found
  end
end
