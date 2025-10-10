class PagesController < WebController
  def home
    @days = Day.order(:number)
  end

  def about
  end
end
