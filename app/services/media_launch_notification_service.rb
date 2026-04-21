class MediaLaunchNotificationService
  def self.call!(delivery: :deliver_later)
    sent_count = 0

    MediaSubscription.find_each do |subscription|
      MediaSubscriptionMailer.media_launched(subscription).public_send(delivery)
      sent_count += 1
    end

    sent_count
  end
end
