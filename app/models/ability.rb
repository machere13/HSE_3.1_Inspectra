class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user&.email_verified?

    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      can :manage, Day
      can :manage, Article
      can :manage, ContentItem
      can :read, :admin_panel
      can :manage, JwtSecretRotation
    elsif user.moderator?
      can :read, Day
      can :update, Day
      can :read, Article
      can :update, Article
      can :read, ContentItem
      can :update, ContentItem
    else
      can :read, Day
      can :read, Article
      can :read, ContentItem
    end
  end
end

