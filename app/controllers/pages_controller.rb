class PagesController < WebController
  layout :determine_layout

  def home
    @active_days = Day.visible_now.order(number: :desc)
    @expired_days = Day.where('expires_at <= ?', Time.current).order(number: :desc)
  end

  def about
  end

  def plug
  end

private

  def determine_layout
    if action_name == 'plug'
      'plug'
    else
      'application'
    end
  end
end
