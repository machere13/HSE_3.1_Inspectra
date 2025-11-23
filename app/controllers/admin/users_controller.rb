class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user_access, only: [:show, :edit, :update]

  def index
    authorize! :read, User
    @role_filter = params[:role]
    
    users_scope = User.all
    
    if @role_filter.present? && User.roles.key?(@role_filter)
      users_scope = users_scope.where(role: @role_filter)
    end
    
    @pagy, @users = pagy(users_scope.order(created_at: :desc), items: 50)
    
    @stats = {
      total: User.count,
      super_admins: User.super_admin.count,
      admins: User.admin.count,
      moderators: User.moderator.count,
      regular: User.user.count
    }
  end

  def show
    @user_achievements = @user.user_achievements.includes(:achievement).order(created_at: :desc)
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: t('admin.users.update.success')
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user_access
    authorize! :read, @user
    authorize! :update, @user if action_name == 'update'
  end

  def user_params
    params.require(:user).permit(:email, :role, :email_verified)
  end
end

