class Admin::ContentItemsController < Admin::BaseController
  before_action :set_day
  before_action :set_content_item, only: [:show, :edit, :update, :destroy]

  def index
    @content_items = @day.content_items.order(:position)
    authorize! :read, ContentItem
  end

  def show
    authorize! :read, @content_item
  end

  def new
    @content_item = @day.content_items.new
    authorize! :create, @content_item
  end

  def create
    attrs = build_attributes_with_metadata
    @content_item = @day.content_items.new(attrs)
    authorize! :create, @content_item
    attach_file(@content_item)
    if @content_item.save
      redirect_to admin_day_content_item_path(@day, @content_item), notice: 'Контент добавлен'
    else
      flash.now[:alert] = @content_item.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! :update, @content_item
  end

  def update
    authorize! :update, @content_item
    attrs = build_attributes_with_metadata
    @content_item.assign_attributes(attrs)
    attach_file(@content_item)
    if @content_item.save
      redirect_to admin_day_content_item_path(@day, @content_item), notice: 'Контент обновлён'
    else
      flash.now[:alert] = @content_item.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @content_item
    @content_item.destroy
    redirect_to admin_day_content_items_path(@day), notice: 'Контент удалён'
  end

  private

  def set_day
    @day = Day.find_by!(number: params[:day_id]) rescue Day.find(params[:day_id])
  end

  def set_content_item
    @content_item = @day.content_items.find(params[:id])
  end

  def content_item_params
    params.require(:content_item).permit(:kind, :title, :body, :url, :position, :article_id)
  end

  def build_attributes_with_metadata
    permitted = content_item_params
    raw_meta = params.dig(:content_item, :metadata)
    return permitted if raw_meta.nil?

    if raw_meta.is_a?(String)
      raw = raw_meta.strip
      if raw.blank?
        permitted[:metadata] = {}
      else
        begin
          permitted[:metadata] = JSON.parse(raw)
        rescue JSON::ParserError
          @content_item ||= @day.content_items.new(permitted)
          @content_item.errors.add(:metadata, 'Некорректный JSON')
          raise ActiveRecord::RecordInvalid.new(@content_item)
        end
      end
    elsif raw_meta.is_a?(ActionController::Parameters) || raw_meta.is_a?(Hash)
      permitted[:metadata] = raw_meta.to_unsafe_h if raw_meta.respond_to?(:to_unsafe_h)
      permitted[:metadata] ||= raw_meta
    end

    permitted
  end

  def attach_file(record)
    uploaded = params.dig(:content_item, :file)
    return unless uploaded.present?
    record.file.attach(uploaded)
  end
end


