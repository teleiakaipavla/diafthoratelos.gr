source 'http://rubygems.org'

gem 'rails', '3.2.6'

if RUBY_PLATFORM !~ /mswin|mingw/
  gem 'rdiscount', :git => 'git://github.com/ricodigo/rdiscount.git'

  gem 'ruby-stemmer', '~> 0.8.2', :require => 'lingua/stemmer'
  gem 'sanitize', '2.0.3'

  gem 'magic'
  gem 'mini_magick', '~> 2.3'
  gem 'nokogiri'
  gem 'mechanize'
else
  gem 'maruku', '0.6.0'
end
gem 'maruku'

# ui
gem 'haml', '>= 3.1.3'
gem 'sass', '>= 3.1.10'
gem 'compass-colors', '0.9.0'
gem 'fancy-buttons', '1.1.1'
gem 'kaminari'
gem 'mustache'
gem 'poirot', :git => 'git://github.com/dcu/poirot.git'


# mongodb
gem 'bson', '1.4.0'
gem 'bson_ext', '1.4.0'

gem 'mongo', '1.4.0'
gem 'mongoid', :git => 'git://github.com/mongoid/mongoid.git', :branch => '2.4.0-stable'

gem 'mongoid_ext', :git => 'git://github.com/dcu/mongoid_ext.git'

gem 'mongo_store', :git => 'https://github.com/Houdini/mongo_store.git'
#gem 'redis'
#gem 'redis-store'
#gem 'redis-rails'

# utils
gem 'whatlanguage', '1.0.0'
gem 'uuidtools', '~> 2.1.1'
gem 'magent', '0.6.2'
gem 'bug_hunter', :git => 'git://github.com/ricodigo/bug_hunter.git'

gem 'goalie', '~> 0.0.4'
gem 'dynamic_form'
gem 'rinku', '~> 1.2.2', :require => 'rails_rinku'

gem 'rack-recaptcha', '0.2.2', :require => 'rack/recaptcha'

gem 'twitter-text', '1.1.8'
gem 'twitter_oauth'
gem 'social_widgets', :git => 'https://git.gitorious.org/social_widgets/social_widgets.git'
gem 'stripe'
gem 'pdfkit' # apt-get install wkhtmltopdf

gem 'geoip'
gem 'rubyzip', '0.9.4', :require => 'zip/zip'

gem 'newrelic_rpm'

# authentication
gem 'omniauth', '~> 0.3.0'
gem 'oa-openid', '~> 0.3.0', :require => 'omniauth/openid'
gem 'oa-oauth', '~> 0.3.0', :require => 'omniauth/oauth'

gem 'multiauth', :git => 'http://github.com/dcu/multiauth.git'

gem 'orm_adapter'
gem 'devise', '~> 1.4.0'

gem 'whenever', :require => false
gem 'rack-ssl', :require => false

gem 'state_machine', '1.1.2'

gem 'xapian-ruby', '1.2.7.1'
gem 'xapit', :git => 'git://github.com/kuadrosx/xapit.git'
group :assets do
  gem 'compass-rails'
  gem 'compass'
  gem 'sass-rails', "  ~> 3.2.0"
  gem 'uglifier'
end
gem 'yui-compressor'
gem 'jquery-rails'

group :deploy do
  gem 'capistrano', '2.9.0', :require => false
  gem 'ricodigo-capistrano-recipes', '~> 0.1.3', :require => false
  gem 'unicorn', '4.1.1', :require => false
  gem 'therubyracer'
end

group :scripts do
  gem 'eventmachine', '~> 0.12.10'
  gem 'em-websocket', '~> 0.3.0'
  gem 'twitter', '1.7.2'
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'launchy'
  gem 'ffaker'
  gem 'simplecov'
  gem 'autotest'
  gem 'fabrication'
end

group :development do
  gem 'pry'
  gem 'pry-rails'
  gem 'database_cleaner'
  gem 'rspec', '>= 2.0.1'
  gem 'rspec-rails', '>= 2.0.1'
  gem 'remarkable_mongoid', '>= 0.5.0'
  gem 'hpricot'
  gem 'ruby_parser'
  gem 'niftier-generators', '0.1.2'
  gem 'ruby-prof'
  gem 'tunnlr_connector', :git => 'git://github.com/dcu/tunnlr_connector.git', :branch => 'patch-1', :require => 'tunnlr'
end
