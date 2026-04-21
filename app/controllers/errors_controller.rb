class ErrorsController < WebController
  include ErrorsPageRendering

  layout 'application'

  def report_problem
    message = params[:message].to_s.strip
    if message.blank? || message.length > 20_000
      redirect_back fallback_location: root_path, alert: t('errors.report_invalid_message')
      return
    end

    report = ErrorReport.new(
      page_url: params[:page_url].to_s.truncate(2_048),
      status_code: params[:status_code].to_s.truncate(16),
      reporter_email: current_user&.email,
      message: message
    )

    if report.save
      Rails.logger.info({
        event: 'problem_report',
        url: report.page_url,
        status_code: report.status_code,
        reporter_email: report.reporter_email,
        message: report.message.truncate(2_000)
      }.to_json)
      begin
        ErrorReportMailer.new_report(report).deliver_later
      rescue StandardError => e
        Rails.logger.error({
          event: 'error_report_mail_delivery_failed',
          error: e.class.name,
          message: e.message,
          report_id: report.id
        }.to_json)
      end
      redirect_back fallback_location: root_path, notice: t('errors.report_thanks')
    else
      redirect_back fallback_location: root_path, alert: report.errors.full_messages.to_sentence
    end
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
