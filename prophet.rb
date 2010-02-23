require 'pp'
class Prophet

	def initialize(&block)
		@endpoints = {}
		instance_eval &block
	end

	def method_missing(name, *params, &block)
		c = EndpointConfig.new(name.to_sym, &block)
		@endpoints[params.pop] = c
	end
    
    def up!
        @endpoints.each do |uri, cfg| 
            type = cfg.type.to_s

            begin
                require "endpoints/%s/%s_endpoint" % [type, type]
                t = Thread.new do
                    ep = Object.module_eval("::#{type.capitalize}Endpoint", __FILE__, __LINE__).create(cfg.options)
                    ep.start
                end
                t.run
            rescue
                print "Cannot initialize endpoint %s" % type
            end
        end
    end
    
	def connect!
		DRb.start_service
        @subjects = []
        @endpoints.each{ |uri, cfg| cfg.live_endpoint = DRbObject.new(nil, "druby://#{uri}") }
        @q = Queue.new

        @worker = Thread.new do
            loop do
                s = @q.pop
                @endpoints.each do |uri, cfg|
                    cfg.live_endpoint.notify(cfg.events[:announce].call(s)) if cfg.live_endpoint.respond_to? :notify 
                end
            end
        end
        @worker.run
	end

    def announce(message)
        @q << message
    end

    def kill!
        @worker.kill
    end

    def finalize
        @worker.kill if @worker.alive?
    end
    
    alias :connect :connect!  
    alias :up :up! 
end

class EndpointConfig
	attr_reader :events, :options, :type
    attr_accessor :live_endpoint
	def initialize(type, &block)
		@type = type
		@events = {}
		@options = {}
        @live_endpoint = nil
		instance_eval(&block) if block_given?
	end
	
	def config(opts)
		@options = opts
	end
	
	def on(event, &block)
		@events[event] = block
	end
	
end




@p = Prophet.new do
	bot 'localhost:2099' do
		config :nick => 'botty_xyz', :server => 'irc.freenode.net', :channel=>'#botty'
		on :announce do |msg|
			msg.upcase
		end
	end
	
	#bot 'foo:2099' do
	#	config :nick => 'foop', :server => 'irc.foo.net'
	#	on :announce do
	#		msg.upcase
	#	end
	#end
	
	#not implemented yet
	#jabber 'localhost:2093' do
	#	config :user => 'u', :password => 'p'
	#	on :announce do
	#		erb msg, :newmsg
	#	end
	#end
end



