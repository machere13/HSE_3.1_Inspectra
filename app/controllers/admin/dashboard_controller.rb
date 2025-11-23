class Admin::DashboardController < Admin::BaseController
  def index
    authorize! :read, :admin_dashboard
    @stats = {
      users: {
        total: User.count,
        super_admins: User.super_admin.count,
        admins: User.admin.count,
        moderators: User.moderator.count,
        regular: User.user.count,
        email_verified: User.where(email_verified: true).count,
        email_unverified: User.where(email_verified: false).count
      },
      weeks: {
        total: Week.count,
        visible: Week.visible_now.count,
        expired: Week.where('expires_at <= ?', Time.current).count
      },
      articles: {
        total: Article.count
      },
      content_items: {
        total: ContentItem.count
      },
      achievements: {
        total: Achievement.count,
        completed: UserAchievement.where.not(completed_at: nil).count,
        in_progress: UserAchievement.where(completed_at: nil).count
      },
      recent_users: User.order(created_at: :desc).limit(10)
    }
  end
end

