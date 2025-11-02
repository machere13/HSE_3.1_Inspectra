namespace :jwt do
  desc 'Cleanup expired revoked tokens'
  task cleanup_expired: :environment do
    count = RevokedToken.cleanup_expired
    puts "Cleaned up #{count} expired revoked tokens"
  end

  desc 'Rotate JWT secret'
  task rotate_secret: :environment do
    new_secret = JwtSecretService.rotate_secret
    puts "JWT secret rotated successfully"
    puts "New secret: #{new_secret[0..20]}..."
  end
end
