source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

# dependencies
gem 'bigdecimal'

gem 'io-console'

gem 'mutex_m'

gem 'prettier_print', '~> 1.2'

gem 'syntax_tree', '~> 6.2'

gem 'syntax_tree-haml', '~> 4.0'

gem 'syntax_tree-rbs', '~> 1.0'

gem 'sprockets-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.2'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 6.4.3'
# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'rubocop', '~> 1.77', require: false

gem 'devise', '~> 4.9'

gem 'bootstrap-sass', '~> 3.4.1'

gem 'jquery-rails', '~> 4.6.0'

gem 'pundit', '~> 2.5.0'

gem 'aws-sdk-s3'

# sidekiq
gem 'sidekiq'
gem 'sidekiq-scheduler'

# tailwindcss
gem 'cssbundling-rails'
gem 'jsbundling-rails'
gem 'tailwindcss-rails'

gem 'image_processing'
gem 'streamio-ffmpeg'

gem 'kaminari'
gem 'kaminari-tailwind'
gem 'ransack'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'rspec-rails'

  gem 'shoulda-matchers'

  gem 'factory_bot_rails'

  gem 'rails-controller-testing'

  # Capybara, the library that allows us to interact with the browser using Ruby
  gem 'capybara'

  # This gem helps Capybara interact with the web browser.
  gem 'webdrivers', '= 5.3.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.9.0'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'
  # Fake data
  gem 'faker'

  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'rack-mini-profiler', require: false

# For memory profiling (requires Ruby MRI 2.1+)
gem 'memory_profiler'

# For call-stack profiling flamegraphs (requires Ruby MRI 2.0.0+)
gem 'fast_stack'    # For Ruby MRI 2.0
gem 'flamegraph'
gem 'stackprof'     # For Ruby MRI 2.1+
