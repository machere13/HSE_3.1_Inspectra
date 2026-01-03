class ErrorsController < WebController
  layout 'application'
  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
      format.all  { render plain: '404 Not Found', status: :not_found }
    end
  end
end


