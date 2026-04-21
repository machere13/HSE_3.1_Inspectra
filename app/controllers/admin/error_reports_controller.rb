class Admin::ErrorReportsController < Admin::BaseController
  def index
    authorize! :read, ErrorReport

    reports_scope = ErrorReport.order(created_at: :desc)
    @pagy, @error_reports = pagy(reports_scope, items: 50)
    @stats = {
      total: ErrorReport.count
    }
  end
end
