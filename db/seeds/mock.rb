# frozen_string_literal: true

require 'faker'

Faker::Config.locale = :en
_prev_enforce = I18n.enforce_available_locales
I18n.enforce_available_locales = false

def reset_mock_content
  puts 'Очистка мок-данных (Weeks, Articles, ContentItems)...'
  ContentItem.delete_all
  Article.delete_all
  Week.delete_all
end

def create_mock_weeks_with_content(total_weeks)
  current_week = AppConfig::Content.current_week || 1
  total_weeks.times do |i|
    number = i + 1

    next if number > current_week

    week = Week.create!(
      number: number,
      title: "Мок-Неделя #{number}",
      description: Faker::Lorem.paragraph(sentence_count: 1)
    )

        articles = Array.new(rand(2..4)) do |j|
          Article.create!(
            week: week,
            title: "Статья #{j+1}",
            body: Faker::Lorem.paragraphs(number: 3).join("\n\n")
          )
        end

        kinds = %w[image gif video audio link]
        rand(4..10).times do |pos|
          kind = kinds.sample
          attrs = {
            week: week,
            kind: kind,
            position: pos,
            title: Faker::Lorem.sentence(word_count: 3).chomp('.')
          }
          
          case kind
          when 'image'
            images_urls = [
              'https://i.pinimg.com/1200x/ae/9a/a9/ae9aa9ac9a2f6cc5aab13940e71cac03.jpg',
              'https://i.pinimg.com/736x/48/12/fe/4812fee2262a1214ee5ba403b637e069.jpg',
              'https://i.pinimg.com/736x/aa/ff/f4/aafff43260f4642eef5d36a13c55a472.jpg'
            ]
            attrs[:url] = images_urls.sample
          when 'gif'
            gifs_urls = [
              'https://i.pinimg.com/originals/5e/ea/2b/5eea2b92e254e5d704e748fc5eecefaa.gif',
              'https://i.pinimg.com/originals/11/f8/e2/11f8e2b6d99b43dddb539c4109856cf0.gif',
              'https://i.pinimg.com/originals/e4/5f/b8/e45fb8fe81987bda7e417f64e7c35346.gif'
            ]
            attrs[:url] = gifs_urls.sample
          when 'video'
            video_urls = [
              'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'
            ]
            attrs[:url] = video_urls.sample
          when 'audio'
            audio_urls = [
              'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
              'https://www2.cs.uic.edu/~i101/SoundFiles/BabyElephantWalk60.wav',
              'https://www2.cs.uic.edu/~i101/SoundFiles/StarWars3.wav'
            ]
            attrs[:url] = audio_urls.sample
          when 'link'
            attrs[:url] = Faker::Internet.url
          end
          
          ContentItem.create!(attrs)
        end
  end

  puts "Создано мок-недель: #{Week.count}, статей: #{Article.count}, контента: #{ContentItem.count}"
end

reset_mock_content
create_mock_weeks_with_content(15)
I18n.enforce_available_locales = _prev_enforce
