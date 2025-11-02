namespace :jwt do
  desc 'Cleanup expired revoked tokens'
  task cleanup_expired: :environment do
    count = RevokedToken.cleanup_expired
    puts "Cleaned up #{count} expired revoked tokens"
  end

  desc 'Rotate JWT secret manually'
  task :rotate_secret, [:rotated_by] => :environment do |_t, args|
    rotated_by = args[:rotated_by] || 'rake_task'
    new_secret = JwtSecretService.rotate_secret(
      rotation_type: 'manual',
      rotated_by: rotated_by,
      metadata: { source: 'rake_task', timestamp: Time.current.iso8601 }
    )
    puts "JWT secret rotated successfully"
    puts "Rotation ID: #{JwtSecretRotation.last.id}"
    puts "Rotated by: #{rotated_by}"
    puts "New secret preview: #{new_secret[0..20]}..."
  end

  desc 'Check if JWT secret rotation is due'
  task check_rotation_due: :environment do
    stats = JwtSecretService.rotation_stats
    puts "Last rotation: #{stats[:last_rotation] || 'Never'}"
    puts "Next rotation due: #{stats[:next_rotation_due] || 'Now'}"
    puts "Rotation due: #{stats[:rotation_due] ? 'YES' : 'NO'}"
    
    if stats[:rotation_due]
      puts "\n⚠️  WARNING: Secret rotation is due!"
      exit 1
    end
  end

  desc 'Show JWT secret rotation statistics'
  task rotation_stats: :environment do
    stats = JwtSecretService.rotation_stats
    puts "\n=== JWT Secret Rotation Statistics ==="
    puts "Last rotation: #{stats[:last_rotation] || 'Never'}"
    puts "Next rotation due: #{stats[:next_rotation_due] || 'Now'}"
    puts "Rotation due: #{stats[:rotation_due] ? 'YES' : 'NO'}"
    puts "\nTotal rotations: #{stats[:total_rotations]}"
    puts "  - Automatic: #{stats[:automatic_rotations]}"
    puts "  - Manual: #{stats[:manual_rotations]}"
    puts "  - Emergency: #{stats[:emergency_rotations]}"
    
    if stats[:recent_rotations].any?
      puts "\nRecent rotations:"
      stats[:recent_rotations].each do |r|
        puts "  [#{r[:id]}] #{r[:rotated_at]} - #{r[:rotation_type]} by #{r[:rotated_by]}"
      end
    end
    puts "=====================================\n"
  end
end
