class ArticlesController < WebController
  def show
    wid = params[:week_id].to_s
    @week = Week.find_by(number: wid.to_i) || Week.find_by(number: wid) || Week.find_by(id: wid)
    return head :not_found unless @week
    @article = @week.articles.find(params[:id])
    track_view!
  end

  private

  def track_view!
    return unless current_user&.email_verified?
    result = ContentViewTracker.new(current_user).track!
    return unless result&.xp_awarded&.positive?

    parts = [t('pages.content_view.xp_awarded', xp: result.xp_awarded, streak: result.new_streak)]
    Array(result.new_titles).each do |title|
      parts << t('pages.profile.titles.earned_toast', title: title.name)
    end
    flash.now[:notice] = parts.join(' · ')
  end
end
