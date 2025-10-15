if Rails.env.development?
  require 'sprockets/cache'
  Rails.application.config.assets.configure do |env|
    env.cache = Sprockets::Cache::MemoryStore.new
  end
end


