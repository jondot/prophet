# sudo gem install twitter

require 'twitter'
require 'drb'

class TwitterEndpoint

    def initialize(opts={})
        @user = opts[:user]
        @password = opts[:password]
        @drb_uri = opts[:drb_uri] || 'localhost:2098'
    end
    
    def start_drb_service
      DRb.start_service("druby://#{@drb_uri}", self)
    end
    
    def announce(msg)
        @client.update(msg)
    end
    
    def start
        t = Thread.new do
            httpauth = Twitter::HTTPAuth.new(@user, @password)
            @client = Twitter::Base.new(httpauth)
            start_drb_service
        end
        t.run
    end
end