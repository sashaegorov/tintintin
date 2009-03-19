port = 3030

desc "Start the app server"
task :start => :stop do
  puts "Starting the blog"
  system "ruby main.rb -p #{port} > access.log 2>&1 &"
end

# code lifted from rush
def process_alive(pid)
  ::Process.kill(0, pid)
  true
rescue Errno::ESRCH
  false
end

def kill_process(pid)
  ::Process.kill('TERM', pid)

  5.times do
    return if !process_alive(pid)
    sleep 0.5
    ::Process.kill('TERM', pid) rescue nil
  end

  ::Process.kill('KILL', pid) rescue nil
rescue Errno::ESRCH
end

desc "Stop the app server"
task :stop do
  m = `netstat -lptn | grep 0.0.0.0:#{port}`.match(/LISTEN\s*(\d+)/)
  if m
    pid = m[1].to_i
    puts "Killing old server #{pid}"
    kill_process(pid)
  end
end

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
      Post.create post.merge(:slug => Post.make_slug(post[:title]))
    end
  end
end
