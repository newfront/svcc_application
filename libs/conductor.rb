class Conductor < EventMachine::Connection
  
  # runs automatically on object instantiation
  def initialize(*args)
    # setup some global variables
    @connection = Hashie::Mash.new
    # has this user registered?
    @registered = false
    # subscribed channels
    @channels = {}
  end
  
  # Runs immediately following the constructor (initialize)
  #  Used to capture the EventMachine instance id
  def post_init
    puts "connection established"
    
    # store the eventmachine connection object id
    @connection.id = self.object_id
  end
  
  def receive_data(data)
    
    # parse out the data...
    data = Message.parse(data)
    # Event Dispatcher
    dispatch_event(data)
  end
  
  # read packet params and respond accordingly
  def dispatch_event(data)
    puts "Event Dispatcher Invoked"
    
    unless !data.has_key? "type"
      puts "message type #{data['type'].to_s}"
      
      # switch event action based on message type
      case data['type']
        when "register"
          puts "user wishes to register. check auth_key first"
          self.register(data)
        when "subscribe"
          puts "user wishes to subscribe to a channel"
          self.subscribe(data)
        when "message"
          # message: to:channel,from:uuid,type:message,text:message,visibility:private
          puts "user wishes to send a message"
      end
      
    else
      # if the socket is connected but no post_init data was sent
      # then we want to kill the connection, since this is probably an unauthorized
      # user....
      
      puts "data doesn't have key type"
      self.close_connection_after_writing
    end
      
  end
  
  # have user subscribe to a channel
  def subscribe(data)
    # @channels (local tracker)
    # push channel name into subscribe list, if and only if not already in subscribe list
  end
  
  def send_message(data)
    
    #TODO : spec out base message format
    
    #begin
    #  $connections[to].event_machine_connection.send_data(message) if $connections.has_key? to
    #  self.close_connection_after_writing
    #rescue Exception => e
    #  puts "Error (send_message(#{to.to_s},#{from.to_s},#{message.to_s})) : #{e.to_s}"
    #end
    
  end
  
  # Register an entity on the Conductor Server
  #  uuid, first_name, last_name, auth_key, type
  #  TODO need to marshal dump and load EventMachine instance for messaging...
  
  def register(data)
    unless @registered
      @user = Hashie::Mash.new(data)
      @user.event_machine_connection_id = @connection.id
      @user.event_machine_connection = self
      puts "uuid: #{@user.uuid}"
      puts "first_name: #{@user.first_name}"
      puts "last_name: #{@user.last_name}"
      puts "software_key: #{@user.auth_key}"
      puts "type: #{@user.type}"
      puts "identifier (em): #{@user.event_machine_connection_id.to_s}"
  
      # store user in global hash - (this could also be in mongodb,mysql,redis,etc)
      $connections.store(@user.uuid,@user)
      puts $connections.inspect
    
      unless !$connections.has_key? @user.uuid
        puts "user is registered and in $connections hash"
        @registered = true
        $ws_notifier.call("#{@user.uuid} just registered on the server")
      else
        puts "epic fail. shutting down now"
      end
    else
      puts "user is already registered. ignoring re-registration"
    end
    
  end
  
  # remove the user from memory
  def unregister(uuid)
    if $connections.has_key? (@user.uuid)
      $connections.delete(@user.uuid)
    end
  end
  
  # called automatically when the Socket connection is disconnected (remote connection)
  def unbind
    puts "connection #{@connection.id.to_s} unbound"
    begin
      unless !@registered
        self.unregister(@user.uuid)
        $ws_notifier.call("#{@user.uuid} just left the server")
      else
        puts "Never registered. So don't try to kill connection data"
      end
    rescue
      puts "Error (unbind). Couldn't delete from hash"
    end
    puts "Person is no longer connected"
  end
  
end