# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

ENV['SEED'] ||= 'mock'

def load_seed_file(name)
  path = Rails.root.join('db', 'seeds', "#{name}.rb")
  load(path) if File.exist?(path)
end

if Rails.env.production?
  ENV['SEED'] = 'real' if ENV['SEED'] == 'all'
end

case ENV['SEED']
when 'real'
  load_seed_file('real')
when 'mock'
  load_seed_file('mock')
when 'all'
  load_seed_file('real')
  load_seed_file('mock')
else
  puts "Неизвестное значение SEED=#{ENV['SEED']}. Используйте real|mock|all."
end
