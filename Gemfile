source 'https://rubygems.org'
ruby "2.0.0"

# gem 'rails', '~> 3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Bundle my "fixed" Rails branch on GitHub instead:
gem 'rails', :git    => 'git://github.com/alexeymuranov/rails.git',
             :branch => 'backport-to-3-2'

# Bundle Rails from my local directory instead:
# gem 'rails', '~> 3.2.0', :path => "~/Development/rails"

# gem 'will_paginate'  # pagination
gem 'kaminari'  # pagination

# gem 'spreadsheet'  # to generate XLS (Excel 2003 XML is used instead)

# gem 'inherited_resources'  # for lazy resourceful controllers

# gem 'focused_controller'  # alternative way to define and use controllers

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-ui-rails' # jQuery UI

gem 'haml'

# gem 'draper'  # provides decorators (similar to presenters)

# gem 'formtastic'

gem 'bourbon'  # better Sass

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

gem 'rubyzip'  # reading and writing zip files

gem 'ruby-duration'  # Immutable time duration type

group :development do
  gem 'sqlite3'
  gem 'debugger'
  gem 'better_errors'
  gem 'binding_of_caller' # more debugging tools to use with 'better_errors'
  gem 'annotate'   # annotate models
  gem 'rails-erd'  # generate models' diagram in PDF
end

group :test do
  # Pretty printed test output:
  gem 'turn',     :require => false
  # gem 'spork'                        # speeds up running tests
end

group :production do
  gem 'pg'  # PostgreSQL for Heroku
end
