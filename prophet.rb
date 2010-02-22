require 'drb'
require 'thread'

class Prophet
    def initialize(*uris)
        DRb.start_service
        @subjects = []
        uris.each{ |uri| @subjects << DRbObject.new(nil, "druby://#{uri}") }
        @q = Queue.new

        @worker = Thread.new do
            loop do
                s = @q.pop
                @subjects.each { |subj| subj.notify(s) if subj.respond_to? :notify }
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
end

