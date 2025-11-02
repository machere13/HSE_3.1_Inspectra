class Api::V1::AchievementsController < ApplicationController
  include JwtHelper
  
  before_action :block_test_endpoints_in_production, only: [:test_interactive_completion, :test_consecutive_days, :test_registration_order]
  
  def index
    achievements = Achievement.all
    render json: achievements, status: :ok
  end
  
  def user_achievements
    require_auth
    return unless logged_in?
    
    user_achievements = current_user.user_achievements.includes(:achievement)
    
    render json: {
      completed: user_achievements.completed.map { |ua| format_user_achievement(ua) },
      in_progress: user_achievements.in_progress.map { |ua| format_user_achievement(ua) }
    }, status: :ok
  end
  
  def by_category
    category = params[:category]
    
    unless Achievement.categories.key?(category)
      return render json: { error: 'Неверная категория' }, status: :bad_request
    end
    
    achievements = Achievement.where(category: category)
    render json: achievements, status: :ok
  end
  
  def test_interactive_completion
    require_auth
    return unless logged_in?
    
    content_category = params[:content_category] || 'dev_diving'
    
    service = AchievementService.new(current_user)
    service.check_achievements_for_interactive_completion(content_category)
    
    user_achievements = current_user.user_achievements.includes(:achievement)
    
    render json: {
      message: "Проверка достижений выполнена для темы: #{content_category}",
      updated_achievements: user_achievements.map { |ua| format_user_achievement(ua) }
    }, status: :ok
  end
  
  def test_consecutive_days
    require_auth
    return unless logged_in?
    
    days = params[:days]&.to_i || 7
    
    service = AchievementService.new(current_user)
    service.check_achievements_for_consecutive_days(days)
    
    user_achievements = current_user.user_achievements.includes(:achievement)
    
    render json: {
      message: "Проверка достижений выполнена для #{days} дней подряд",
      updated_achievements: user_achievements.map { |ua| format_user_achievement(ua) }
    }, status: :ok
  end
  
  def test_registration_order
    require_auth
    return unless logged_in?
    
    service = AchievementService.new(current_user)
    service.check_achievements_for_registration_order
    
    user_achievements = current_user.user_achievements.includes(:achievement)
    
    render json: {
      message: "Проверка достижений по порядку регистрации выполнена (ID: #{current_user.id})",
      updated_achievements: user_achievements.map { |ua| format_user_achievement(ua) }
    }, status: :ok
  end
  
  private
  
  def block_test_endpoints_in_production
    if Rails.env.production?
      head :not_found
      return false
    end
  end
  
  def format_user_achievement(user_achievement)
    {
      id: user_achievement.id,
      achievement: {
        id: user_achievement.achievement.id,
        name: user_achievement.achievement.name,
        description: user_achievement.achievement.description,
        category: user_achievement.achievement.category,
        progress_type: user_achievement.achievement.progress_type,
        progress_target: user_achievement.achievement.progress_target
      },
      progress: user_achievement.progress,
      progress_percentage: user_achievement.progress_percentage,
      completed_at: user_achievement.completed_at,
      completed: user_achievement.completed?
    }
  end
end
