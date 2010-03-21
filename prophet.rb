require 'pp'
require 'bunny'
require 'endpoints/endpoint'

class Prophet

	def initialize(&block)
		@endpoints = {}
		instance_eval &block
        
        initialize_exchange
	end

    def initialize_exchange
        x = Bunny.new(:logging => true)
        x.start
        @exchange = x.exchange('messages')
    end

	def method_missing(name, *params, &block)
		c = EndpointConfig.new(name.to_sym, &block)
		@endpoints[params.pop] = c
	end
    
    def up!
        @endpoints.each do |uri, cfg| 
            type = cfg.type.to_s
            cfg.options[:uri] = uri
            begin
                require "endpoints/%s/%s_endpoint" % [type, type]
                ep = Object.module_eval("::#{type.capitalize}Endpoint", __FILE__, __LINE__).new(cfg.options)
                ep.start
            rescue
                print "Cannot initialize endpoint %s" % type
            end
        end
    end

    def announce(message)
        # broadcast
        @endpoints.each do |uri, cfg|
            @exchange.publish(cfg.events[:announce].call(message), :key => uri) # todo: validate before announce that announce exist
        end
    end

    alias :up :up! 
end

class EndpointConfig
	attr_reader :events, :options, :type

	def initialize(type, &block)
		@type = type
		@events = {}
		@options = {}
		instance_eval(&block) if block_given?
	end
	
	def config(opts)
		@options = opts
	end
	
	def on(event, &block)
		@events[event] = block
	end
	
end

