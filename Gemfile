source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

# Use postgres as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.2'

# Add gem to allow users to authenticate with Yale CAS server
gem 'rubycas-client', :git => 'git://github.com/rubycas/rubycas-client.git'

# Add paperclip to allow users to upload content 
gem 'paperclip', '4.2.4'

# Add aws-sdk for S3 storage of user-uploaded content
gem 'aws-sdk', '~> 1.55.0'

# add ffmpeg wrapper for video transcoding and thumbnail generation
gem 'paperclip-ffmpeg', '~> 1.0.1'

# allow file uploads to happen as background processes
gem 'delayed_paperclip'

# use puma server in production
gem 'puma', '2.11.1'

# add rmagick gem to call the imagemagick assets on heroku
gem 'rmagick'

# add bower js package manager
gem 'bower-rails'

# add datepicker dependency
gem 'momentjs-rails', '>= 2.9.0'

# add datepicker utils
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'

# add faker for generating seed data
gem 'faker'

# add pagination gem to support continuous scroll
gem 'will_paginate', '~> 3.0.5'

# add gem to support multiple file upload with progress bar
gem 'jquery-fileupload-rails'

# add gem to enable respond_to calls in rails 4.2
gem 'responders', '~> 2.0'

# add mimetypes gem to support mimetype extensions
gem 'mime-types'

# add support for cors headers
gem 'rack-cors', :require => 'rack/cors'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  # add web-console gem to support upgrade to rails 4.2
  gem 'web-console', '~> 2.0'
end

group :production do
  # enable compression on heroku production assets
  gem 'heroku-deflater'

  # add heroku requirement
  gem 'rails_12factor'
end

# add the version of ruby used locally
ruby '2.3.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
