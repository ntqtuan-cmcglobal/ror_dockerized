require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDISCLOUD_URL', 'redis://redis:6379/0') }
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDISCLOUD_URL', 'redis://redis:6379/0') }
  config.logger.level = Logger::DEBUG
end
