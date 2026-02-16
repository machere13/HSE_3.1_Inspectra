class Api::V1::ContentItemsController < ApplicationController
  def index
    @week = find_week_by_param(params[:week_id])
    @pagy, @content_items = pagy(@week.content_items.includes(:article).order(:position))
    render_success(
      data: @content_items.as_json(include: [:article]),
      pagy: @pagy
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Неделя не найдена')
  end

  private

  def find_week_by_param(param)
    Week.visible_now.find_by(number: param) || Week.visible_now.find_by(id: param) || (raise ActiveRecord::RecordNotFound)
  end
end
