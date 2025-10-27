namespace :admin do
  desc "Grant admin rights to a user: rails admin:grant[email@example.com]"
  task :grant, [:email] => :environment do |_, args|
    email = args[:email].to_s.strip
    abort 'Usage: rails admin:grant[email]' if email.blank?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    user.update!(admin: true, email_verified: true)
    puts "OK: #{email} is now admin"
  end

  desc "Revoke admin rights: rails admin:revoke[email@example.com]"
  task :revoke, [:email] => :environment do |_, args|
    email = args[:email].to_s.strip
    abort 'Usage: rails admin:revoke[email]' if email.blank?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    user.update!(admin: false)
    puts "OK: #{email} is no longer admin"
  end

  desc "List all admins"
  task :list => :environment do
    unless User.column_names.include?('admin')
      abort 'users.admin column missing. Run migrations first.'
    end
    users = User.where(admin: true).order(:email)
    if users.any?
      users.each { |u| puts u.email }
    else
      puts 'No admins found'
    end
  end
end


