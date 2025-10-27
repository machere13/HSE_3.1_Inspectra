# frozen_string_literal: true

require 'yaml'

def achievements_data
  path = Rails.root.join('db', 'seeds', 'achievements.yml')
  raw = YAML.safe_load_file(path)
  list = raw && raw['achievements'] ? raw['achievements'] : []
  list.map { |h| h.respond_to?(:deep_symbolize_keys) ? h.deep_symbolize_keys : h }
end

achievements_data.each do |achievement_data|
  Achievement.find_or_create_by!(name: achievement_data[:name]) do |achievement|
    achievement.assign_attributes(achievement_data)
  end
end

puts "Создано достижений: #{Achievement.count}"

if Day.count.zero?
  day = Day.create!(
    number: 1,
    title: 'День 1',
    description: 'Описание дня 1'
  )
  article = Article.create!(day: day, title: 'Введение', body: 'Добро пожаловать! Это реальный контент без моков.')
  ContentItem.create!(day: day, kind: 'article', position: 1, title: 'Статья дня', article: article)
  puts 'Создан базовый день с одной статьёй.'
end
