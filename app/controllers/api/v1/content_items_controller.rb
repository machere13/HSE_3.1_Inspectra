class Api::V1::ContentItemsController < ApplicationController
  def index
    @week = Week.find(params[:week_id])
    @pagy, @content_items = pagy(@week.content_items.includes(:article).order(:position))
    render_success(
      data: @content_items.as_json(include: [:article]),
      pagy: @pagy
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Неделя не найдена')
  end
end
