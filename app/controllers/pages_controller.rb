class PagesController < WebController
  layout 'plug', only: [:plug]
  def home
    @days = Day.order(number: :desc)
  end

  def about
  end

  def plug
  end
end
