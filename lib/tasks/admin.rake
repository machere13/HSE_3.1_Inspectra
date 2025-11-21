namespace :admin do
  desc "Set user role: rails admin:set_role[email@example.com,role] (roles: user, moderator, admin, super_admin)"
  task :set_role, [:email, :role] => :environment do |_, args|
    email = args[:email].to_s.strip
    role = args[:role].to_s.strip
    abort 'Usage: rails admin:set_role[email,role]' if email.blank? || role.blank?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    unless User.roles.key?(role)
      abort "Invalid role: #{role}. Valid roles: #{User.roles.keys.join(', ')}"
    end

    user.update!(role: role, email_verified: true)
    puts "OK: #{email} is now #{role}"
  end

  desc "Grant admin rights (backward compatibility): rails admin:grant[email@example.com]"
  task :grant, [:email] => :environment do |_, args|
    email = args[:email].to_s.strip
    abort 'Usage: rails admin:grant[email]' if email.blank?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    user.update!(role: :admin, email_verified: true)
    puts "OK: #{email} is now admin"
  end

  desc "Revoke admin rights (backward compatibility): rails admin:revoke[email@example.com]"
  task :revoke, [:email] => :environment do |_, args|
    email = args[:email].to_s.strip
    abort 'Usage: rails admin:revoke[email]' if email.blank?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    user.update!(role: :user)
    puts "OK: #{email} is no longer admin"
  end

  desc "List all admins and super_admins"
  task :list => :environment do
    unless User.column_names.include?('role')
      abort 'users.role column missing. Run migrations first.'
    end
    users = User.where(role: [:admin, :super_admin]).order(:email)
    if users.any?
      users.each { |u| puts "#{u.email} (#{u.role})" }
    else
      puts 'No admins found'
    end
  end
end


