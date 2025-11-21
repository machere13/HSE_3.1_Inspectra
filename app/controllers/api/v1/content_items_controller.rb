class Api::V1::ContentItemsController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @pagy, @content_items = pagy(@day.content_items.includes(:article).order(:position))
    render_success(
      data: @content_items.as_json(include: [:article]),
      pagy: @pagy
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'День не найден')
  end
end
