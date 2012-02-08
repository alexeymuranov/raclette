source 'http://rubygems.org'

# gem 'rails', '~> 3.2.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Bundle my "fixed" Rails branch on GitHub instead:
gem 'rails', '~> 3.2.0', :git => 'git://github.com/alexeymuranov/rails.git', :branch => 'backport-to-3-2'

# Bundle Rails from my local directory instead:
# gem 'rails', '~> 3.2.0', :path => "~/Development/rails"

# gem 'will_paginate'  # pagination
gem 'kaminari'  # pagination

# gem 'squeel'  # queries without SQL

# gem 'spreadsheet'  # to generate XLS (Excel 2003 XML is used instead)

# gem 'inherited_resources'  # for lazy resourceful controllers
# gem 'active_presenter'  # lets see what it is good for (seems broken)
gem 'active_conductor'  # and this too

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'jquery-rails'

gem 'haml'  # use HAML templates (instead of ERB)

# gem 'slim' # use Slim templates (instead of HAML and ERB)

gem 'draper'  # provides decorators (similar to presenters)

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
  gem 'rails-erd'  # generate models' diagram in PDF
end

group :test do
  # Pretty printed test output:
  gem 'turn',     :require => false  # disable for now, to get used to the usual test output
  # gem 'spork'                        # speeds up running tests
end

group :production do
  gem 'pg'  # PostgreSQL for Heroku
end
