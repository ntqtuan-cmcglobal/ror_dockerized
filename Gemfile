source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

# Core Rails and dependencies
gem 'pg'
gem 'puma', '~> 6.4.3'
gem 'rails', '~> 8.0.2'
gem 'sprockets-rails'

# Asset management
gem 'bootsnap', require: false
gem 'bootstrap-sass', '~> 3.4.1'
gem 'coffee-rails', '~> 4.2'
gem 'cssbundling-rails'
gem 'image_processing'
gem 'jquery-rails', '~> 4.6.0'
gem 'jsbundling-rails'
gem 'sass-rails', '~> 5.0' # Uncomment if needed
gem 'tailwindcss-rails'
gem 'terser'
gem 'uglifier', '>= 1.3.0'

# Authentication & Authorization
gem 'bcrypt', '~> 3.1.7'
gem 'devise', '~> 4.9'
gem 'doorkeeper'
gem 'pundit', '~> 2.5.0'

# Background jobs & scheduling
gem 'sidekiq'
gem 'sidekiq-scheduler'

# Profiling & debugging
gem 'benchmark'
gem 'fast_stack'
gem 'flamegraph'
gem 'memory_profiler'
gem 'rack-mini-profiler', require: false
gem 'stackprof'

# Performance
gem 'turbolinks'

# Data & API
gem 'aws-sdk-s3'
gem 'jbuilder', '~> 2.5'
gem 'kaminari'
gem 'kaminari-tailwind'
gem 'ransack'
gem 'redis', '~> 4.0'
gem 'rswag'
gem 'streamio-ffmpeg'

# Syntax & formatting
gem 'bigdecimal'
gem 'io-console'
gem 'mutex_m'
gem 'prettier_print', '~> 1.2'
gem 'syntax_tree', '~> 6.2'
gem 'syntax_tree-haml', '~> 4.0'
gem 'syntax_tree-rbs', '~> 1.0'

# Fake data
gem 'faker'

# Linting & type checking
gem 'rubocop', '~> 1.77', require: false
gem 'sorbet', group: :development
gem 'sorbet-runtime'
gem 'tapioca', require: false, group: %i[development test]

# Windows support
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Payments
gem 'stripe', '~> 15.3'

# Development & test groups
group :development, :test do
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'webdrivers', '= 5.3.0'
end

group :development do
  gem 'letter_opener'
  gem 'listen', '>= 3.9.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'simplecov', require: false
end
