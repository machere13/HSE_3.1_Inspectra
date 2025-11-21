class Admin::DaysController < Admin::BaseController
  load_and_authorize_resource

  def index
    @pagy, @days = pagy(Day.order(:number), items: 20)
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

  def day_params
    params.require(:day).permit(:number, :title, :description, :published_at, :expires_at)
  end
end


