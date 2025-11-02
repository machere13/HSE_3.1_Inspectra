class Admin::JwtSecretsController < Admin::BaseController
  def index
    @stats = JwtSecretService.rotation_stats
    @rotations = JwtSecretRotation.recent.limit(50)
  end

  def rotate
    rotation_type = params[:rotation_type] || 'manual'
    metadata = {
      source: 'admin_ui',
      rotated_by_user_id: current_user.id,
      rotated_by_user_email: current_user.email,
      timestamp: Time.current.iso8601
    }

    begin
      JwtSecretService.rotate_secret(
        rotation_type: rotation_type,
        rotated_by: "#{current_user.email} (#{current_user.id})",
        metadata: metadata
      )
      
      redirect_to admin_jwt_secrets_path, notice: 'JWT секрет успешно ротирован'
    rescue => e
      Rails.logger.error "[Admin JWT Rotation Error] #{e.class}: #{e.message}"
      redirect_to admin_jwt_secrets_path, alert: "Ошибка при ротации: #{e.message}"
    end
  end

  def stats
    render json: JwtSecretService.rotation_stats
  end
end

