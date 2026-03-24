class ErrorsController < WebController
  include ErrorsPageRendering

  layout 'application'

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
