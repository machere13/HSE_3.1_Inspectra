class Api::V1::ContentItemsController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @content_items = @day.content_items.includes(:article).order(:position)
    render json: @content_items, include: [:article]
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'День не найден' }, status: :not_found
  end
end
