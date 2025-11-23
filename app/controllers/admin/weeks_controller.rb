class Admin::WeeksController < Admin::BaseController
  before_action :set_week, only: [:show, :edit, :update, :destroy]
  before_action :authorize_week_access, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @weeks = pagy(Week.order(:number), items: 20)
    authorize! :read, Week
  end

  def show; end

  def new
    @week = Week.new
    authorize! :create, @week
  end

  def create
    @week = Week.new(week_params)
    authorize! :create, @week
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

  def set_week
    id = params[:id].to_s
    @week = Week.find_by(number: id.to_i) || Week.find_by(number: id) || Week.find_by(id: id)
    raise ActiveRecord::RecordNotFound unless @week
  end

  def authorize_week_access
    authorize! :read, @week
    authorize! :update, @week if ['edit', 'update', 'destroy'].include?(action_name)
  end

  def week_params
    params.require(:week).permit(:number, :title, :description, :published_at, :expires_at)
  end
end

