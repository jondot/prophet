class Endpoint
    def start
        start_endpoint
        
        Thread.new do
            b = Bunny.new(:logging => true)
            # start a communication session with the amqp server
            b.start
             
            # create/get queue
            q = b.queue(self.class.name + $$.to_s)
             
            # create/get exchange
            exch = b.exchange('messages')
             
            # bind queue to exchange
            q.bind(exch, :key => @uri)
             
            # subscribe to queue
            q.subscribe do |msg|
                announce msg[:payload]
            end
             
            # Close client
            b.stop
        end
    end
      
end