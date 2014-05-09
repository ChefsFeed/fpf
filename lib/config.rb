require 'redis'
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: 'fpf' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: 'fpf' }
end
