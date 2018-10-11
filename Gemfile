# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails'
gem 'pg'
gem 'puma'
gem 'sass-rails'

gem 'jbuilder'
# gem 'redis', '~> 4.0'
# gem 'bcrypt', '~> 3.1.7'
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'hirb'
  gem 'rails-flog', require: 'flog'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'
  gem 'test-queue'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'
  gem 'bullet'
  gem 'rubocop', require: false
  gem 'guard-livereload', require: false
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'chromedriver-helper'
end

group :production do
  gem 'uglifier'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'config'
gem 'haml-rails'
gem 'webpacker', github: 'rails/webpacker'
gem 'devise'
gem 'hashie'
gem 'rein'
gem 'seed-fu', '~> 2.3'
gem 'bootsnap', require: false
gem 'hashie-forbidden_attributes'
gem 'selenium-webdriver'
