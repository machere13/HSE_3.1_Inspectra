class ErrorsController < WebController
  include ErrorsPageRendering

  layout 'application'

  def report_problem
    message = params[:message].to_s.strip
    if message.blank? || message.length > 20_000
      redirect_back fallback_location: root_path, alert: t('errors.report_invalid_message')
      return
    end
    url = params[:page_url].to_s.truncate(2_048)
    code = params[:status_code].to_s.truncate(16)
    Rails.logger.info({ event: 'problem_report', url: url, status_code: code, message: message.truncate(2_000) }.to_json)
    redirect_back fallback_location: root_path, notice: t('errors.report_thanks')
  end

  def show
    assign_error_page!(params[:status_code])
    respond_to do |format|
      format.html { render :show, status: @status_code }
      format.json do
        render json: { error: Rack::Utils::HTTP_STATUS_CODES[@status_code] || 'Error' }, status: @status_code
      end
      format.any { head @status_code }
    end
  end

  def not_found
    assign_error_page!(404)
    respond_to do |format|
      format.html { render :show, status: :not_found }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
      format.all { head :not_found }
    end
  end
end
