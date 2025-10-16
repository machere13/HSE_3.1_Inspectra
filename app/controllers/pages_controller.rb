class PagesController < WebController
  def home
    @days = Day.order(number: :desc)
  end

  def about
  end
end
