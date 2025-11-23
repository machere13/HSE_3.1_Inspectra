class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user&.email_verified?

    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      can :manage, Week
      can :manage, Article
      can :manage, ContentItem
      can :read, :admin_panel
      can :manage, JwtSecretRotation
      can :read, User
      can :update, User
      can :read, :admin_dashboard
    elsif user.moderator?
      can :read, Week
      can :update, Week
      can :read, Article
      can :update, Article
      can :read, ContentItem
      can :update, ContentItem
    else
      can :read, Week
      can :read, Article
      can :read, ContentItem
    end
  end
end

