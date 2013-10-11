source 'https://rubygems.org'

# Sinatra and friends
gem 'sinatra', require: 'sinatra/base'
gem 'sinatra-r18n', require: 'sinatra/r18n'
gem 'sinatra-contrib'
gem 'haml'

# TODO: Replace builder with Nokogiri 
# gem 'builder'

gem 'sequel'
gem 'sqlite3'
gem 'rdiscount'
gem 'RedCloth'
gem 'unicode'

group :development, :test do
	gem 'puma'
	gem 'cucumber'
	gem 'capybara'
	gem 'rspec'
  # Mac only. Requred to improve performance
  # TODO: Check is it still necessary
  # gem 'rb-fsevent', require: false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-livereload'
  gem 'guard-cucumber'
  gem 'guard-shell'
  gem 'terminal-notifier-guard'
end