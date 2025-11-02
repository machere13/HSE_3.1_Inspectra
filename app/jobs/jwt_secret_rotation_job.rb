class JwtSecretRotationJob < ApplicationJob
  queue_as :default

  def perform
    return unless JwtSecretService.rotation_due?

    Rails.logger.info "[JWT Secret Rotation Job] Starting automatic rotation"
    
    JwtSecretService.rotate_secret(
      rotation_type: 'automatic',
      rotated_by: 'jwt_secret_rotation_job',
      metadata: {
        source: 'automatic_job',
        triggered_at: Time.current.iso8601,
        previous_rotation: JwtSecretService.last_rotation_at&.iso8601
      }
    )
    
    Rails.logger.info "[JWT Secret Rotation Job] Automatic rotation completed successfully"
  rescue => e
    Rails.logger.error "[JWT Secret Rotation Job Error] #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    raise
  end
end

