source 'http://rubygems.org'

# gem 'rails', '~> 3.1.0'

# Bundle local Rails instead:
# gem 'rails', '~> 3.1.0', :path => "../../rails"

# Bundle my GitHub working Rails branch instead:
gem 'rails', '~> 3.1.0', :git => 'git://github.com/alexeymuranov/rails.git', :branch => 'my_work_fixes'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'will_paginate'  # pagination
gem 'kaminari'  # pagination

# gem 'squeel'  # queries without SQL (does not work?)

# gem 'spreadsheet'  # to generate XLS (Excel 2003 XML is used instead)

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.0'
  gem 'coffee-rails', '~> 3.1.0'
  gem 'uglifier'
end

gem 'jquery-rails'

gem 'haml'  # use HAML templating (sister project of SASS) instead of ERB

gem 'draper'  # This gem provides decorators (much like presenters)

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :development do
  gem 'sqlite3'
  # To use debugger
  # gem 'ruby-debug19', :require => 'ruby-debug'  # brocken since rails 3.1.1 ?
  # gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'  # annotate models
  gem 'annotate'   # annotate models
  gem 'rails-erd'  # generate PDF documenting models
end

group :test do
  # Pretty printed test output
  gem 'turn',     :require => false
  # gem 'minitest', :require => false  # had to add manually to get rid of some errors
  gem 'spork'                        # added to speed up test running
end

group :production do
  gem 'pg'  # PostgreSQL for Heroku
end
