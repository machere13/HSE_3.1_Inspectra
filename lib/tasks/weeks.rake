namespace :weeks do
  desc 'Создать недостающие недели после последней существующей'
  task create_missing: :environment do
    last_week = Week.order(:number).last
    
    if last_week.nil?
      puts 'Нет существующих недель. Создайте первую неделю вручную.'
      next
    end
    
    next_number = last_week.number + 1
    created_count = 0
    
    while next_number <= 24
      if Week.exists?(number: next_number)
        puts "Неделя #{next_number} уже существует, пропускаем"
        next_number += 1
        next
      end
      
      begin
        week = Week.create!(
          number: next_number,
          title: "Неделя #{next_number}",
          description: nil,
          published_at: last_week.expires_at,
          expires_at: last_week.expires_at + AppConfig::Content.week_expiration_hours
        )
        puts "Создана неделя #{next_number}"
        created_count += 1
        last_week = week
        next_number += 1
      rescue StandardError => e
        puts "Ошибка при создании недели #{next_number}: #{e.message}"
        break
      end
    end
    
    puts "Создано недель: #{created_count}"
  end
end
