class Admin::MediaSubscriptionsController < Admin::BaseController
  def index
    authorize! :read, MediaSubscription

    subscriptions_scope = MediaSubscription.order(created_at: :desc)
    @pagy, @media_subscriptions = pagy(subscriptions_scope, items: 50)
    @stats = {
      total: MediaSubscription.count
    }
  end
end
