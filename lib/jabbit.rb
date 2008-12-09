require 'rubygems'
require 'xmpp4r-simple'
require 'eventmachine'
require 'rest_client'

class Jabbit
  # help message if jabbing goes wrong. super simple DSL for posts
  HELP_MESSAGE = <<-HELP
Try again!
title without points. tags: tag1, tag2. body here<code>puts 'hello'</code>"
  HELP

  def initialize
    config = YAML.load_file 'config/config.yml'
    @scanty_url  = config["scanty"]["url_base"]
    @jabber = Jabber::Simple.new(config["jabbit"]["login"], config["jabbit"]["password"])
    fork_jab
  end

  private
  #some links about backgrounding processes (more on del.icio.us/joahking)
  #   http://nutrun.com/weblog/distributed-programming-with-jabber-and-eventmachine/
  #   http://devblog.famundo.com/articles/category/xmpp4r-jabber
  #   http://nubyonrails.com/articles/about-this-blog-beanstalk-messaging-queue
  #   http://playtype.net/past/2008/2/6/starling_and_asynchrous_tasks_in_ruby_on_rails/
  def fork_jab
    EM.run do
      EM::PeriodicTimer.new(1) do
        @jabber.received_messages do |message|
          begin
            RestClient.post("#{@scanty_url}/posts",
                            new_post_form(message),
                            :http_user_agent => 'jabbit')
            msg = 'Ok'
          rescue
            #TODO is an exception the good way? Rack with HTTP error code?
          end
          @jabber.deliver(message.from, msg || HELP_MESSAGE)
        end
      end
    end
  end

  def new_post_form(message)
    params = extract_params_from_message(message.body)
    {
      :title => params[:title],
      :tags => params[:tags],
      :body =>  params[:body],
      :author => message.from
    }
  end

  # super simple DSL for posts
  # title without points. tags:tag1, tag2. body here<code>puts 'hello'</code>
  def extract_params_from_message(message)
    parts = message.split '.' # period is the separator
    params = { :title => parts[0] }
    body_start = if parts[1] =~ /\s*tags\s*:/
                   # remove 'tags:' from string, notice the join ', ' scanty expects:
                   # tags: tag comma space tag
                   params[:tags] = parts[1].gsub(/[\s]*tags\s*:\s*/,'').
                     split(',').collect { |w| w.strip }.join(', ')
                   2 # body starts here
                 else
                   1 # body starts here
                 end
    # we need to reassemble body
    params[:body] = parts[body_start..parts.length].join('.')
    params
  end

#   def disconnect
#     @jabber.disconnect
#   end

#   def add_friend(friend)
#     @jabber.add(@friend)
#   end

end

