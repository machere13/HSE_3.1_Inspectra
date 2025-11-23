class Admin::WeeksController < Admin::BaseController
  load_and_authorize_resource

  def index
    @pagy, @weeks = pagy(Week.order(:number), items: 20)
  end

  def show; end

  def new
    @week = Week.new
  end

  def create
    @week = Week.new(week_params)
    if @week.save
      redirect_to admin_week_path(@week), notice: 'Неделя создана'
    else
      flash.now[:alert] = @week.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @week.update(week_params)
      redirect_to admin_week_path(@week), notice: 'Неделя обновлена'
    else
      flash.now[:alert] = @week.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @week.destroy
    redirect_to admin_weeks_path, notice: 'Неделя удалена'
  end

  private

  def week_params
    params.require(:week).permit(:number, :title, :description, :published_at, :expires_at)
  end
end

