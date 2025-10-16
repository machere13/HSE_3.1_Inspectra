# frozen_string_literal: true

require 'faker'

Faker::Config.locale = :en
_prev_enforce = I18n.enforce_available_locales
I18n.enforce_available_locales = false

def reset_mock_content
  puts 'Очистка мок-данных (Days, Articles, ContentItems)...'
  ContentItem.delete_all
  Article.delete_all
  Day.delete_all
end

def create_mock_days_with_content(total_days)
  current_day = ENV.fetch('CURRENT_DAY', '1').to_i
  total_days.times do |i|
    number = i + 1

    if number < current_day
      published_at = Time.current - 48.hours
      expires_at   = published_at + 24.hours
    elsif number == current_day
      published_at = Time.current
      expires_at   = published_at + 24.hours
    else
      next
    end

    day = Day.create!(
      number: number,
      title: "Мок-День #{number}",
      description: Faker::Lorem.paragraph(sentence_count: 1),
      published_at: published_at,
      expires_at: expires_at
    )

    articles = Array.new(rand(2..4)) do |j|
      Article.create!(
        day: day,
        title: "Статья #{j+1}",
        body: Faker::Lorem.paragraphs(number: 3).join("\n\n")
      )
    end

    kinds = %w[image gif video audio link article]
    rand(4..10).times do |pos|
      kind = kinds.sample
      attrs = {
        day: day,
        kind: kind,
        position: pos,
        title: Faker::Lorem.sentence(word_count: 3).chomp('.')
      }
      attrs[:article] = articles.sample if kind == 'article'
      ContentItem.create!(attrs)
    end
  end

  puts "Создано мок-дней: #{Day.count}, статей: #{Article.count}, контента: #{ContentItem.count}"
end

reset_mock_content
create_mock_days_with_content(15)
I18n.enforce_available_locales = _prev_enforce
