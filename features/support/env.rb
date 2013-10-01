# Paths
ROOT_PATH = File.join(File.dirname(__FILE__), '..', '..')
DB_FILE_NAME = "test#{rand(1000)}.db"
DB_FILE = File.join(ROOT_PATH, DB_FILE_NAME)

ENV['DATABASE_URL'] = "sqlite://#{DB_FILE_NAME}"
ENV['RACK_ENV'] = 'test'

require File.join(ROOT_PATH, 'main.rb')
require File.join(File.dirname(__FILE__), 'helpers.rb')

require 'capybara'
require 'capybara/cucumber'
require 'rspec'
require 'r18n-core'

Capybara.app = Scanty::Blog

class ScantyBlogWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  ScantyBlogWorld.new
end

at_exit do
  delete_file! DB_FILE
end
