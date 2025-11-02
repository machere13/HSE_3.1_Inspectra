Rails.configuration.x.schedule = ActiveSupport::OrderedOptions.new

Rails.configuration.x.schedule.start_date = begin
  raw = ENV['SCHEDULE_START_DATE']
  raw.present? ? Date.parse(raw) : Date.current
rescue ArgumentError
  Date.today
end

Rails.configuration.x.schedule.switch_hour = ENV.fetch('SCHEDULE_SWITCH_HOUR', '3').to_i

if defined?(Rails::Console) == false && Rails.env.production?
  # Пример настройки через cron:
  # 0 3 * * 0 cd /path/to/app && bundle exec rails runner "JwtSecretRotationJob.perform_now"
  # 
  # Или через whenever gem в schedule.rb:
  # every 7.days, at: '3:00 am' do
  #   runner "JwtSecretRotationJob.perform_now"
  # end
end


