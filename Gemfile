# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.3.3'

gem 'nokogiri', '1.6.7.2' # 1.6.8 doesnt install on some pcs. Remove when fixed

###########
# General #
###########

gem 'rails', '~> 5.1'
gem 'bundler', '>= 1.8.4'

gem 'clarat_base', github: 'clarat-org/clarat_base'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', '~> 4.1.12'
gem 'rails-observers', '= 0.1.5' # observers got extracted since rails 4

# Translations
gem 'rails-i18n'
gem 'i18n-js'
gem 'easy_translate'

gem 'dynamic_sitemaps', github: 'efqdalton/dynamic_sitemaps',
                        branch: 'adds-custom-storages'

# Platforms Ruby
platforms :ruby do
  gem 'sqlite3', group: :test # sqlite3 for inmemory testing db
  gem 'therubyracer' # js runtime
  gem 'pg', group: %i[production staging development] # postgres
end

# Templating with slim
gem 'slim-rails'

#######################
# CLARADMIN SPECIFICS #
#######################

gem 'rails_admin_clone' # must come before rails_admin to work correctly
gem 'rails_admin'
# gem 'rails_admin_nested_set'
gem 'rails_admin_nestable'
gem 'cancan' # role based auth for rails_admin

gem 'devise'
gem 'pundit'

gem 'trailblazer'
# gem 'trailblazer-loader'
gem 'trailblazer-rails'
gem 'trailblazer-endpoint', github: 'trailblazer/trailblazer-endpoint'
gem 'trailblazer-cells'
gem 'cells'
gem 'cells-slim'
gem 'cells-rails'
gem 'reform' # , '~> 2.1.0'
# gem 'reform-rails'
gem 'roar', github: 'apotonick/roar', branch: 'master'
gem 'roar-jsonapi', github: 'trailblazer/roar-jsonapi'
gem 'multi_json'
gem 'will_paginate'

gem 'simple_form'
gem 'dry-validation'
gem 'dry-types'

# Internal Search Implementation
gem 'pg_search'

# for sidekiq web interface
gem 'sinatra', '>= 1.3.0'

# Schedulable jobs for sidekiq
gem 'sidekiq-cron', '~> 0.4.0'
gem 'rufus-scheduler', '3.2.2'

gem 'httparty'

# converting between unicode and ascii urls
gem 'simpleidn'
# Faraday for http requests and middleware for redirects
gem 'faraday'
gem 'faraday_middleware'

# ActiveRecord Extension
gem 'rails_or'

########################
# For Heroku & Add-Ons #
########################

gem 'rack-cache'
gem 'memcachier'
gem 'dalli' # Memcached Client
gem 'kgio'

group :production, :staging do
  gem 'rails_12factor' # heroku recommends this
  gem 'heroku-deflater' # gzip compression
end

# Logging
gem 'lograge' # opinionated slimmer logs for production

# Puma server
gem 'puma'

#############################
# Assets: CSS /  JavaScript #
#############################

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2.0'

gem 'hogan_assets' # TODO: deprecated!
group :assets do # TODO: deprecated!
  gem 'haml' # TODO: deprecated!
end # TODO: deprecated!

source 'https://rails-assets.org' do
  gem 'rails-assets-lodash' # (aka underscore) diverse js methods
  gem 'rails-assets-jquery', '2.2.4' # version cap only for rails_admin
  gem 'rails-assets-qtip2'
  gem 'rails-assets-shariff'
  gem 'rails-assets-algoliasearch' # search client
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-font-awesome'
  gem 'rails-assets-d3'
  gem 'rails-assets-nestable2'
end

gem 'react_on_rails', '< 7.0.0'

#####################
# Dev/Test Specific #
#####################

group :development do
  # startup
  gem 'spring' # faster rails start

  # errors
  gem 'better_errors'
  gem 'binding_of_caller'

  # debugging in chrome with RailsPanel
  gem 'meta_request'

  # requires graphviz to generate
  # entity relationship diagrams
  gem 'rails-erd', require: false

  gem 'foreman'
end

group :test do
  gem 'memory_test_fix' # Sqlite inmemory fix
  gem 'rake'
  gem 'database_cleaner'
  gem 'fakeredis'
  gem 'fakeweb', '~> 1.3'
  gem 'webmock'
  gem 'pry-rescue'

  # testing emails
  gem 'email_spec'

  # js tests
  gem 'capybara-selenium'

  # ActionCable tests - remove once their PRs are merged by rails
  gem 'action-cable-testing'
end

group :development, :test do
  # debugging
  gem 'pry-rails' # pry is awsome
  gem 'hirb' # hirb makes pry output even more awesome
  gem 'pry-byebug' # kickass debugging
  gem 'pry-stack_explorer' # step through stack
  gem 'pry-doc' # read ruby docs in console

  # test suite
  gem 'rails-controller-testing'
  gem 'minitest', '5.10.1' # Testing using Minitest
  gem 'minitest-matchers'
  gem 'minitest-line'
  gem 'launchy' # save_and_open_page
  gem 'shoulda'
  gem 'minitest-rails-capybara'
  gem 'mocha'

  # test suite additions
  gem 'rails_best_practices'
  gem 'brakeman' # security test: execute with 'brakeman'
  gem 'rubocop', '0.49.1' # style enforcement
  gem 'colorize' # output coloring

  # Code Coverage
  gem 'simplecov', require: false
  gem 'coveralls', require: false
  gem 'codeclimate-test-reporter', require: false

  # dev help
  gem 'thin' # Replace Webrick
  gem 'bullet' # Notify about n+1 queries
  gem 'letter_opener' # emails in browser
  gem 'timecop' # time travel!
  gem 'dotenv-rails' # handle environment variables
end

group :development, :test, :staging do
  gem 'factory_girl_rails'
  gem 'ffaker'
end
