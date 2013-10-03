# encoding: UTF-8

pid_file = File.expand_path('tintintin.pid')

def alive?(pid)
  ::Process.kill(0, pid)
  true
rescue Errno::ESRCH
  false
end

def shutdown(pid)
  puts 'Stopping Tintintin application...'
  ::Process.kill('TERM', pid)
  5.times do
    return if !alive?(pid)
    sleep 2
    ::Process.kill('TERM', pid) rescue nil
  end
  ::Process.kill('KILL', pid) rescue nil
rescue Errno::ESRCH
end

desc 'Start Tintintin application'
task :start do
  require 'rack'
  Rack::Server.start (options={config: 'config.ru'})
end

namespace :start do
  desc 'Start Tintintin application in background'
  task :background do
    pid = fork do
      require 'rack'
      Rack::Server.start (options={
        config: 'config.ru',
        pid: pid_file
      })
    end
  end
end

desc 'Stop Tintintin application'
task :stop do
  pid = ::File.read(pid_file).to_i
  if pid
    shutdown(pid)
  end
end

# TODO:
# desc 'Run Cucumber'
# task :default => [:cucmber]

# TODO: check task below

task :environment do
  require 'main'
  DB = Sequel.connect(sequel_db_uri)
end

task :import => :environment do
  url = ENV['URL'] or raise "No url specified, use URL="

  require 'rest_client'
  posts = YAML.load RestClient.get(url)

  posts.each do |post|
    DB[:posts] << post
  end
end

file 'config/config.yml' => 'config/config.yml.sample' do
  system 'cp config/config.yml.sample config/config.yml'
end

desc "copies the config.yml.sample to config/config.yml"
task :config => 'config/config.yml'

# you have dumped your feather articles to articles.yml with:
# File.open('articles.yml', 'w') do |f|
#   f.puts Article.all.collect { |a|
#     { :created_at => a.published_at,
#       :body => a.content,
#       :published => a.published,
#       :title => a.title, :tags => a.tags }
#   }.to_yaml
# end
# then import them
desc "import from feather posts yml, indicate yaml location with YAML=..."
task :feather => :environment do
  posts = YAML.load_file ENV['YAML']

  posts.each do |post|
    if post[:published]
      post.delete(:published)
      Scanty::Post.create post.merge(:slug => Scanty::Post.make_slug(post[:title]))
    end
  end
end
