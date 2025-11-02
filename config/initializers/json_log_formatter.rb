class JsonLogFormatter < ActiveSupport::Logger::SimpleFormatter
  def call(severity, time, progname, msg)
    log_entry = {
      timestamp: time.utc.iso8601,
      level: severity,
      message: msg.to_s.strip,
      pid: Process.pid
    }
    
    if defined?(Rails) && Rails.application
      log_entry[:env] = Rails.env
      log_entry[:app] = Rails.application.class.module_parent_name.underscore
    end
    
    if (request_id = Thread.current[:request_id])
      log_entry[:request_id] = request_id
    end
    
    exception = $!
    if exception && severity.to_s == 'ERROR'
      log_entry[:exception] = {
        class: exception.class.name,
        message: exception.message,
        backtrace: exception.backtrace&.first(10)
      }
    end
    
    "#{log_entry.to_json}\n"
  end
end
