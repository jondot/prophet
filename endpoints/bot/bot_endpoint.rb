require 'isaac/bot'
require 'bunny'

class BotEndpoint < Endpoint
    def initialize(opts={})
        @uri = opts[:uri] || 'default.botendpoint.com'
        
        @bot = Isaac::Bot.new do
            configure do |c|
              c.nick = opts[:nick] || "gaius_b_#{rand(10).to_s}" 
              c.server = opts[:server] || 'irc.inter.net.il'
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
    
    def announce(msg)
        @bot.notify(msg)
    end
 
    
protected
    def start_endpoint
        Thread.new do
            @bot.start
        end
    end
end

