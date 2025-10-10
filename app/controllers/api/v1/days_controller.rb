class Api::V1::DaysController < ApplicationController
  def index
    @days = Day.includes(:articles, :content_items).order(:number)
    render json: @days, include: [:articles, :content_items]
  end

  def show
    @day = Day.includes(:articles, :content_items).find(params[:id])
    render json: @day, include: [:articles, :content_items]
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'День не найден' }, status: :not_found
  end
end
