require 'drb'
require 'isaac/bot'

class BotEndpoint
    def initialize(opts={})
        @drb_uri = opts[:drb_uri] || 'localhost:2099'
        
        @bot = Isaac::Bot.new do
            configure do |c|
              c.nick = opts[:nick] || "gaius_b_#{rand(10).to_s}" 
              c.server = opts[:server] || 'irc.freenode.net'
              c.port = opts[:port] || 6667
              c.realname = opts[:realname] || 'Gaius Baltar'
              c.verbose = true
              c.version = opts[:version] || '1.0'
              @chan = opts[:channel] || '#bsg4evr'
              @online_quote = opts[:online_quote] || 'On behalf of the people of the Twelve Colonies, I surrender.'
        
            end
             
            on :connect do
              join @chan
              msg @chan, @online_quote
            end
             
            on :error, 401 do
              puts "Ok, #{nick} doesn't exist."
            end
               
            def notify(message) 
              msg @chan, message
            end
            

        end
    end
    
    def start_drb_service
        DRb.start_service("druby://#{@drb_uri}", self)
    end
    
    def announce(msg)
        @bot.notify(msg)
    end
    
    def start
        t = Thread.new do
            start_drb_service
            @bot.start
        end
        t.run
    end
end

