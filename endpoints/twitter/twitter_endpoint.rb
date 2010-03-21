# sudo gem install twitter

require 'twitter'
require 'bunny'

class TwitterEndpoint < Endpoint

    def initialize(opts={})
        @user = opts[:user]
        @password = opts[:password]
        @uri = opts[:uri] || 'localhost:2098'
    end
    
    
    def announce(msg)
        @client.update(msg)
    end
    
protected
    def start_endpoint
        Thread.new do
            puts 'logging in'
            httpauth = Twitter::HTTPAuth.new(@user, @password)
            @client = Twitter::Base.new(httpauth)
        end
    end
end