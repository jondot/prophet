 @p = Prophet.new do
        #bot 'localhost:2099' do
       #     config :nick => 'botty_xyz', :server => 'irc.freenode.net', :channel=>'#botty'
        #    on :announce do |msg|
        #        msg.upcase
        #    end
        #end

        twitter 'foo:2099' do
               config :user => 'prophetrb', :password => 'prophetrb1234'
               on :announce do
                       msg.downcase
               end
        end

        #not implemented yet
        #jabber 'localhost:2093' do
        #       config :user => 'u', :password => 'p'
        #       on :announce do
        #               erb msg, :newmsg
        #       end
        #end
    end

    # spawn up endpoints
    @p.up!

    # few minutes later
    @p.connect!

    # in your application
    @p.announce 'Hello, crewl world!'
