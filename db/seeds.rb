# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

achievements_data = [
  {
    name: "Чёртова дюжина",
    description: "Быть одним из 13 первых зарегистрированных пользователей",
    category: "registration",
    progress_type: "registration_order",
    progress_target: 13
  },
  {
    name: "Первые шаги",
    description: "Просматривать контент 3 дня подряд",
    category: "content_viewing",
    progress_type: "consecutive_days",
    progress_target: 3
  },
  {
    name: "Неделя погружения",
    description: "Просматривать контент 7 дней подряд",
    category: "content_viewing",
    progress_type: "consecutive_days",
    progress_target: 7
  },
  {
    name: "Стальной стример",
    description: "Просматривать контент 14 дней подряд",
    category: "content_viewing",
    progress_type: "consecutive_days",
    progress_target: 14
  },
  {
    name: "Мастер марафона",
    description: "Просматривать контент 30 дней подряд",
    category: "content_viewing",
    progress_type: "consecutive_days",
    progress_target: 30
  },
  {
    name: "Легенда нон-стопа",
    description: "Просматривать контент 90 дней подряд",
    category: "content_viewing",
    progress_type: "consecutive_days",
    progress_target: 90
  },
  {
    name: "Вместе от начала до конца",
    description: "Просматривать контент на протяжении всей жизни платформы",
    category: "content_viewing",
    progress_type: "platform_lifetime",
    progress_target: 1
  },
  {
    name: "Намочил ласты",
    description: "Открыть/пройти 1 интерактив",
    category: "dev_diving",
    progress_type: "total_interactives",
    progress_target: 1
  },
  {
    name: "Погружение в бездну",
    description: "Открыть/пройти 5 интерактивов",
    category: "dev_diving",
    progress_type: "total_interactives",
    progress_target: 5
  },
  {
    name: "Зона сумерек",
    description: "Открыть/пройти 10 интерактивов",
    category: "dev_diving",
    progress_type: "total_interactives",
    progress_target: 10
  },
  {
    name: "Безмолвие глубин",
    description: "Открыть/пройти 15 интерактивов",
    category: "dev_diving",
    progress_type: "total_interactives",
    progress_target: 15
  },
  {
    name: "Абиссальный странник",
    description: "Открыть/пройти 20 интерактивов",
    category: "dev_diving",
    progress_type: "total_interactives",
    progress_target: 20
  },
  {
    name: "Ктулху",
    description: "Открыть/пройти 25 интерактивов",
    category: "dev_diving",
    progress_type: "total_interactives",
    progress_target: 25
  },
  {
    name: "Пыльный манускрипт",
    description: "Открыть/пройти 1 интерактив",
    category: "legacy",
    progress_type: "total_interactives",
    progress_target: 1
  },
  {
    name: "Эхо былых времён",
    description: "Открыть/пройти 5 интерактивов",
    category: "legacy",
    progress_type: "total_interactives",
    progress_target: 5
  },
  {
    name: "Пробуждение руин",
    description: "Открыть/пройти 10 интерактивов",
    category: "legacy",
    progress_type: "total_interactives",
    progress_target: 10
  },
  {
    name: "Мудрость столетий",
    description: "Открыть/пройти 15 интерактивов",
    category: "legacy",
    progress_type: "total_interactives",
    progress_target: 15
  },
  {
    name: "Ожившая легенда",
    description: "Открыть/пройти 20 интерактивов",
    category: "legacy",
    progress_type: "total_interactives",
    progress_target: 20
  },
  {
    name: "Первопредок",
    description: "Открыть/пройти 25 интерактивов",
    category: "legacy",
    progress_type: "total_interactives",
    progress_target: 25
  },
  {
    name: "Ошибка 0x0",
    description: "Открыть/пройти 1 интерактив",
    category: "it_errors",
    progress_type: "total_interactives",
    progress_target: 1
  },
  {
    name: "Bug?",
    description: "Открыть/пройти 5 интерактивов",
    category: "it_errors",
    progress_type: "total_interactives",
    progress_target: 5
  },
  {
    name: "W4RN1NG: null",
    description: "Открыть/пройти 10 интерактивов",
    category: "it_errors",
    progress_type: "total_interactives",
    progress_target: 10
  },
  {
    name: "F4T4L 3RR0R: 0xDE4D C0DE",
    description: "Открыть/пройти 15 интерактивов",
    category: "it_errors",
    progress_type: "total_interactives",
    progress_target: 15
  },
  {
    name: "§¥§T3M F4!L",
    description: "Открыть/пройти 20 интерактивов",
    category: "it_errors",
    progress_type: "total_interactives",
    progress_target: 20
  },
  {
    name: "}0x0x0|_| n07 f0und{",
    description: "Открыть/пройти 25 интерактивов",
    category: "it_errors",
    progress_type: "total_interactives",
    progress_target: 25
  },
  {
    name: "Скрипт-кидди",
    description: "Открыть/пройти 1 интерактив",
    category: "it_security",
    progress_type: "total_interactives",
    progress_target: 1
  },
  {
    name: "Мелкая рыбка",
    description: "Открыть/пройти 5 интерактивов",
    category: "it_security",
    progress_type: "total_interactives",
    progress_target: 5
  },
  {
    name: "Сниффер трафика",
    description: "Открыть/пройти 10 интерактивов",
    category: "it_security",
    progress_type: "total_interactives",
    progress_target: 10
  },
  {
    name: "Красная команда",
    description: "Открыть/пройти 15 интерактивов",
    category: "it_security",
    progress_type: "total_interactives",
    progress_target: 15
  },
  {
    name: "Белый шляп",
    description: "Открыть/пройти 20 интерактивов",
    category: "it_security",
    progress_type: "total_interactives",
    progress_target: 20
  },
  {
    name: "Эксплойт нулевого дня",
    description: "Открыть/пройти 25 интерактивов",
    category: "it_security",
    progress_type: "total_interactives",
    progress_target: 25
  },
  {
    name: "Неофит",
    description: "Открыть/пройти 1 интерактив",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 1
  },
  {
    name: "Посвященный",
    description: "Открыть/пройти 5 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 5
  },
  {
    name: "Адепт",
    description: "Открыть/пройти 10 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 10
  },
  {
    name: "Провидец",
    description: "Открыть/пройти 15 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 15
  },
  {
    name: "Архонт",
    description: "Открыть/пройти 20 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 20
  },
  {
    name: "Демиург",
    description: "Открыть/пройти 25 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 25
  },
  {
    name: "Оракул",
    description: "Открыть/пройти 50 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 50
  },
  {
    name: "Крестный отец",
    description: "Открыть/пройти 75 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 75
  },
  {
    name: "Легенда Кремниевой долины",
    description: "Открыть/пройти 100 интерактивов",
    category: "general",
    progress_type: "total_interactives",
    progress_target: 100
  },
  {
    name: "Последний свидетель",
    description: "Просмотреть контент в последний день жизни платформы",
    category: "content_viewing",
    progress_type: "platform_lifetime",
    progress_target: 1
  }
]

achievements_data.each do |achievement_data|
  Achievement.find_or_create_by!(name: achievement_data[:name]) do |achievement|
    achievement.assign_attributes(achievement_data)
  end
end

puts "Создано #{Achievement.count} достижений"

# Мок на 15 генераций дней с контентом
puts 'Seeding days, articles, and content items...'

Day.destroy_all
Article.destroy_all
ContentItem.destroy_all

15.times do |i|
  number = i + 1
  day = Day.create!(
    number: number,
    title: "Day #{number}",
    description: "Описание дня #{number}"
  )

  articles = Array.new(rand(2..4)) do |j|
    Article.create!(
      day: day,
      title: "Статья #{j+1}",
      body: "I need somebody heeelp #{number}"
    )
  end

  kinds = %w[image gif video audio link article]
  rand(4..10).times do |pos|
    kind = kinds.sample
    attrs = {
      day: day,
      kind: kind,
      position: pos,
      title: "Контент #{kind} #{number}-#{pos+1}",
      metadata: {}
    }

    if kind == 'article'
      attrs[:article] = articles.sample || Article.create!(day: day, title: "Статья автосозданная #{number}", body: "Тело статьи #{number}")
    end

    ContentItem.create!(attrs)
  end
end

puts "Создано дней: #{Day.count}, статей: #{Article.count}, контента: #{ContentItem.count}"
