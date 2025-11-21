# frozen_string_literal: true

# Metrics subscriber for collecting performance metrics
# Tracks database queries, view rendering, and other operations
ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, start, finish, id, payload|
  Thread.current[:request_id] = payload[:request_id]
  
  if payload[:current_user_id]
    Thread.current[:user_id] = payload[:current_user_id]
  end
  
  Thread.current[:metrics] ||= {
    db_queries: 0,
    db_time: 0.0,
    view_time: 0.0,
    total_time: 0.0
  }
  
  duration = ((finish - start) * 1000).round(2)
  Thread.current[:metrics][:total_time] = duration
  Thread.current[:metrics][:view_time] = (payload[:view_runtime] || 0).round(2)
end

ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
  next unless Thread.current[:metrics]
  
  Thread.current[:metrics][:db_queries] += 1
  db_time = ((finish - start) * 1000).round(2)
  Thread.current[:metrics][:db_time] += db_time
end

ActiveSupport::Notifications.subscribe('perform_job.active_job') do |name, start, finish, id, payload|
  duration = ((finish - start) * 1000).round(2)
  job_name = payload[:job].class.name
  
  Rails.logger.info({
    event: 'job_performed',
    job: job_name,
    duration_ms: duration,
    queue: payload[:queue_name],
    arguments: payload[:arguments]&.first(3)
  }.to_json)
end

ActiveSupport::Notifications.subscribe('exception.action_controller') do |name, start, finish, id, payload|
  exception = payload[:exception]
  
  Rails.logger.error({
    event: 'exception',
    exception_class: exception.class.name,
    exception_message: exception.message,
    backtrace: exception.backtrace&.first(5),
    controller: payload[:controller],
    action: payload[:action],
    request_id: payload[:request_id]
  }.to_json)
end

