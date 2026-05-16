# frozen_string_literal: true

require 'yaml'

def load_seed_yaml(filename, root_key)
  path = Rails.root.join('db', 'seeds', filename)
  return [] unless File.exist?(path)
  raw = YAML.safe_load_file(path)
  list = raw && raw[root_key] ? raw[root_key] : []
  list.map { |h| h.respond_to?(:deep_symbolize_keys) ? h.deep_symbolize_keys : h }
end

# Titles загружаются ДО achievements — чтобы achievements могли ссылаться на title_id
load_seed_yaml('titles.yml', 'titles').each do |title_data|
  Title.find_or_create_by!(name: title_data[:name]) do |title|
    title.description = title_data[:description]
  end
end

puts "Создано титулов: #{Title.count}"

load_seed_yaml('achievements.yml', 'achievements').each do |achievement_data|
  title_name = achievement_data.delete(:title_name)
  title = title_name.present? ? Title.find_by(name: title_name) : nil

  achievement = Achievement.find_or_initialize_by(name: achievement_data[:name])
  achievement.assign_attributes(achievement_data)
  achievement.title = title if title
  achievement.save!
end

puts "Создано достижений: #{Achievement.count}"

load_seed_yaml('levels.yml', 'levels').each do |level_data|
  Level.find_or_create_by!(number: level_data[:number]) do |level|
    level.assign_attributes(level_data)
  end
end

puts "Создано уровней: #{Level.count}"

load_seed_yaml('interactives.yml', 'interactives').each do |row|
  variants = row.delete(:variants) || []
  interactive = Interactive.find_or_initialize_by(key: row[:key])
  interactive.assign_attributes(row)
  interactive.save!

  variants.each do |v_data|
    seed_num = v_data[:seed]
    payload = v_data.except(:seed).deep_stringify_keys
    variant = interactive.interactive_variants.find_or_initialize_by(seed: seed_num)
    variant.payload = payload
    variant.save!
  end
end

puts "Создано интерактивов: #{Interactive.count} (вариантов: #{InteractiveVariant.count})"

if Week.count.zero?
  week = Week.create!(
    number: 1,
    title: 'Неделя 1',
    description: 'Описание недели 1'
  )
  Article.create!(week: week, title: 'Введение', body: 'Добро пожаловать! Это реальный контент без моков.')
  puts 'Создана базовая неделя с одной статьёй.'
end
