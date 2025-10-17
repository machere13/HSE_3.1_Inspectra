class AuthController < WebController
  def login; end
  def verify; end
  def forgot; end
  def reset
    @token = params[:token]
  end
end


