# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'yaml'

def achievements_data
  path = Rails.root.join('db', 'seeds', 'achievements.yml')
  raw = YAML.safe_load_file(path)
  list = raw && raw['achievements'] ? raw['achievements'] : []
  list.map { |h| h.respond_to?(:deep_symbolize_keys) ? h.deep_symbolize_keys : h }
end

achievements_data.each do |achievement_data|
  # placeholder to preserve context
end

def seed
  seed_achievements
  reset_content
  create_days_with_content(15)
end

def seed_achievements
  achievements_data.each do |achievement_data|
    Achievement.find_or_create_by!(name: achievement_data[:name]) do |achievement|
      achievement.assign_attributes(achievement_data)
    end
  end
  puts "Создано #{Achievement.count} достижений"
end

def reset_content
  puts 'Seeding days, articles, and content items...'
  ContentItem.delete_all
  Article.delete_all
  Day.delete_all
end

def create_days_with_content(total_days)
  total_days.times do |i|
    number = i + 1
    day = Day.create!(
      number: number,
      title: "Day #{number}",
      description: "Описание дня #{number}"
    )

    articles = create_articles_for_day(day, rand(2..4), number)
    create_content_items_for_day(day, articles, number)
  end

  puts "Создано дней: #{Day.count}, статей: #{Article.count}, контента: #{ContentItem.count}"
end

def create_articles_for_day(day, count, day_number)
  Array.new(count) do |j|
    Article.create!(
      day: day,
      title: "Статья #{j+1}",
      body: "I need somebody heeelp #{day_number}"
    )
  end
end

def create_content_items_for_day(day, articles, day_number)
  kinds = %w[image gif video audio link article]
  rand(4..10).times do |pos|
    kind = kinds.sample
    attrs = {
      day: day,
      kind: kind,
      position: pos,
      title: "Контент #{kind} #{day_number}-#{pos+1}"
    }

    if kind == 'article'
      attrs[:article] = articles.sample || Article.create!(day: day, title: "Статья автосозданная #{day_number}", body: "Тело статьи #{day_number}")
    end

    ContentItem.create!(attrs)
  end
end

seed
