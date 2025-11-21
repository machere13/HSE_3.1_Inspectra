# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

def load_seed_file(name)
  path = Rails.root.join('db', 'seeds', "#{name}.rb")
  load(path) if File.exist?(path)
end

seed_type = AppConfig::App.seed_type
seed_type = 'real' if Rails.env.production? && seed_type == 'all'

case seed_type
when 'real'
  load_seed_file('real')
when 'mock'
  load_seed_file('mock')
when 'all'
  load_seed_file('real')
  load_seed_file('mock')
else
  puts "Неизвестное значение SEED=#{seed_type}. real|mock|all."
end
