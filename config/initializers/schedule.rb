Rails.configuration.x.schedule = ActiveSupport::OrderedOptions.new

Rails.configuration.x.schedule.start_date = begin
  raw = ENV['SCHEDULE_START_DATE']
  raw.present? ? Date.parse(raw) : Date.current
rescue ArgumentError
  Date.today
end

Rails.configuration.x.schedule.switch_hour = ENV.fetch('SCHEDULE_SWITCH_HOUR', '3').to_i


