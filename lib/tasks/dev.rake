namespace :dev do
  desc "Start PostgreSQL server"
  task :start_postgres do
    puts "Starting PostgreSQL server..."
    system('"C:\\PostgreSQL\\bin\\pg_ctl.exe" start -D "C:\\PostgreSQL\\data"')
    puts "PostgreSQL server started!"
  end

  desc "Stop PostgreSQL server"
  task :stop_postgres do
    puts "Stopping PostgreSQL server..."
    system('"C:\\PostgreSQL\\bin\\pg_ctl.exe" stop -D "C:\\PostgreSQL\\data"')
    puts "PostgreSQL server stopped!"
  end

  desc "Start development environment (PostgreSQL + Rails)"
  task :start => :start_postgres do
    puts "Starting Rails server..."
    system('rails server')
  end

  desc "Setup development environment"
  task :setup => :start_postgres do
    puts "Setting up database..."
    system('rails db:create db:migrate')
    puts "Development environment ready!"
  end
end

namespace :lint do
  desc "Lint CSS via Stylelint (uses npx)"
  task :css do
    sh 'npx --yes stylelint "app/assets/stylesheets/**/*.{css,css.erb}"'
  end

  desc "Auto-fix CSS via Stylelint (uses npx --fix)"
  task :css_fix do
    sh 'npx --yes stylelint --fix "app/assets/stylesheets/**/*.{css,css.erb}"'
  end
end