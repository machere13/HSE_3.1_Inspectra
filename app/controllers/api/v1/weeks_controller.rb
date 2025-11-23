class Api::V1::WeeksController < ApplicationController
  def index
    @pagy, @weeks = pagy(Week.visible_now.includes(:articles, :content_items).order(:number))
    render_success(
      data: @weeks.as_json(include: [:articles, :content_items]),
      pagy: @pagy
    )
  end

  def show
    @week = Week.visible_now.includes(:articles, :content_items).find_by(number: params[:id]) ||
           Week.visible_now.includes(:articles, :content_items).find_by(id: params[:id]) ||
           (raise ActiveRecord::RecordNotFound)
    render_success(data: @week.as_json(include: [:articles, :content_items]))
  rescue ActiveRecord::RecordNotFound
    render_not_found(message: 'Неделя не найдена')
  end
end

