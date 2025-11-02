ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, start, finish, id, payload|
  Thread.current[:request_id] = payload[:request_id]
end
