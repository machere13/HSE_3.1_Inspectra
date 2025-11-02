class Api::V1::DaysController < ApplicationController
  def index
    @days = Day.visible_now.includes(:articles, :content_items).order(:number)
    render_success(data: @days.as_json(include: [:articles, :content_items]))
  end

  def show
    @day = Day.visible_now.includes(:articles, :content_items).find_by(number: params[:id]) ||
           Day.visible_now.includes(:articles, :content_items).find_by(id: params[:id]) ||
           (raise ActiveRecord::RecordNotFound)
    render_success(data: @day.as_json(include: [:articles, :content_items]))
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'День не найден')
  end
end
