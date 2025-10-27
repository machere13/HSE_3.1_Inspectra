class Admin::DaysController < Admin::BaseController
  before_action :set_day, only: [:show, :edit, :update, :destroy]

  def index
    @days = Day.order(:number)
  end

  def show; end

  def new
    @day = Day.new
  end

  def create
    @day = Day.new(day_params)
    if @day.save
      redirect_to admin_day_path(@day), notice: 'День создан'
    else
      flash.now[:alert] = @day.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @day.update(day_params)
      redirect_to admin_day_path(@day), notice: 'День обновлён'
    else
      flash.now[:alert] = @day.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @day.destroy
    redirect_to admin_days_path, notice: 'День удалён'
  end

  private

  def set_day
    @day = Day.find_by!(number: params[:id]) rescue Day.find(params[:id])
  end

  def day_params
    params.require(:day).permit(:number, :title, :description, :published_at, :expires_at)
  end
end


