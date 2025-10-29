class PagesController < WebController
  layout :determine_layout

  def home
    @days = Day.order(number: :desc)
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
