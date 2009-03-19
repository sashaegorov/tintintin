require 'rubygems'
require File.dirname(__FILE__) + '/vendor/sinatra/lib/sinatra'

set :app_file, File.expand_path(File.dirname(__FILE__) + '/main.rb')
set :public,   File.expand_path(File.dirname(__FILE__) + '/public')
set :views,    File.expand_path(File.dirname(__FILE__) + '/views')
set :environment, :production

disable :run, :reload

require File.dirname(__FILE__) + "/main.rb"
run Sinatra::Application
