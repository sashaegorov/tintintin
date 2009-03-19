require 'capitate'
require 'capitate/recipes'
set :project_root, File.dirname(__FILE__)

# we only require capinatra for deploy:setup, after that it's not required
# it collapses with capistrano and capitate throwing non set variables exceptions
unless ENV['CAPINATRA'].nil?
  require 'capinatra'
end

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

set :application, "least-significant-bit"
set :domain, "least-significant-bit.com"

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :scm, :git
set :repository, "git://github.com/joahking/scanty.git"
set :deploy_to, "/home/sites/#{application}"

# this is needed if not owner and group will be root, read:
# http://groups.google.com/group/capistrano/browse_thread/thread/5f853a6026e03677/8394c781c9b10faf?lnk=gst&q=root#8394c781c9b10faf
set :admin_runner, "joahking"
# and this is the group the directories will belong, see deploy:set_group task
set :deploy_group, "web"

# capitate mysql:setup variables
#FIXME capistrano pwd prompt was giving an error
set :mysql_admin_password, "YOUR-SQL-ADMIN-PASSWD"
# these 3 are used to generate mysql settings for production
set :db_name, 'lsb_scanty'
set :db_user, 'lsb_scanty_user'
set :db_pass, 'CHANGE-ME'

# this are your scanty admin settings, change!
set :scanty_admin_password, 'CHANGE-ME'
set :admin_cookie_key, 'scanty_admin'
set :admin_cookie_value, '51d6d976913ace58'

# where capinatra apache vhost task will generate your vhost
set :apache_vhost_dir, "/etc/apache2/sites-enabled/"

before "deploy:setup", "mysql:setup", "capinatra:vhost"
after "deploy:setup", "db:configs"
after "deploy:update_code", "db:symlink", "deploy:set_group"

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Sets the group of deploy dirs to the deploy group provided"
  task :set_group do
    sudo "chown -R #{admin_runner}:#{deploy_group} #{deploy_to}"
  end
end

require 'erb'
namespace :db do
  desc "Copies the config yaml"
  task :configs do
    run "mkdir #{shared_path}/config/"
    template = File.read(File.join(File.dirname(__FILE__), 'config', 'config.yml.erb'))
    put ERB.new(template).result(binding), "#{shared_path}/config/config.yml"
  end

  desc "Make symlink for config yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  end
end

namespace :feather do
  desc "imports the published articles from feather yaml"
  task :published do
    set :articles_yml, "/home/#{admin_runner}/articles.yml"
    run "cd #{current_path}; rake feather YAML=#{articles_yml}"
  end
end
