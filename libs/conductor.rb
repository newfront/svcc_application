class Conductor < EventMachine::Connection
  def initialize(*args)
    # stores the connections
    (@@connections ||= Hashie::Mash.new)
  end
  
  # Runs immediately following the constructor (initialize)
  #  Used to capture the EventMachine instance id
  def post_init
    puts "connection established"
    
    # @attribute em_user_connection_id
    @connection = Hashie::Mash.new
    
    # store the eventmachine connection object id
    @connection.id = self.object_id
    
  end
  
  def receive_data(data)
    data = Message.parse(data)
    # Event Dispatcher
    dispatch_event(data)
  end
  
  # read packet params and respond accordingly
  def dispatch_event(data)
    puts "Event Dispatcher"
    puts data.inspect 
    
    #puts Message::send(data)
    #unless !data.has_key?("type")
    #  case data.type
    #    when "message"
    #      #send_message(to,from,message)
    #      send_message(data.to,data.from,data.message.to_s)
    #    when "register"
    #      register(data)
    #  end
    #else
    #  self.close_connection_after_writing
    #end
      
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
  #  uuid, first_name, last_name, software_key, type, application
  #  TODO need to marshal dump and load EventMachine instance for messaging...
  
  def register(data)
    
    #@user = data
    #@user.event_machine_connection_id = @em_user_connection_id
    #@user.event_machine_connection = self
    #puts "uuid: #{@user.uuid}"
    #puts "first_name: #{@user.first_name}"
    #puts "last_name: #{@user.last_name}"
    #puts "software_key: #{@user.software_key}"
    #puts "type: #{@user.type}"
    #puts "application: #{@user.application}"
    #puts "identifier (em): #{@user.event_machine_connection_id}"
  
    # store user in global (update to mongodb)
    #$connections.store(@user.uuid,@user)
    #puts $connections.inspect
    
    #user = User.new
    #user.uuid = @user.uuid
    #user.first_name = @user.first_name
    #user.last_name = @user.last_name
    #user.software_key = @user.software_key
    #user.type = @user.type
    #user.application = @user.application
    #unless !user.save
      # send back 200 OK response
    #  puts "registration successful"
    #  @registered = true
    #else
    #  @registered = false
    #  puts "registration unsuccessful"
    #end
    
  end
  
  # remove the user from memory
  def unregister(uuid)
    
    #if User.where(uuid: "#{uuid.to_s}").delete
    #  puts "(unregister) User is deleted: #{uuid.to_s}"
    #else
    #  puts "(unregister) Error. User couldn't be deleted"
    #end
    
  end
  
  # called automatically when the Socket connection is disconnected (remote connection)
  def unbind
    puts "connection #{@connection.id.to_s} unbound"
    #begin
    #  unless !@registered
    #    self.unregister(@user.uuid)
    #    $connections.delete(@user.uuid) if $connections.has_key? (@user.uuid)
    #  else
    #    puts "Never registered. So don't try to kill connection data"
    #  end
    #rescue
    #  puts "Error (unbind). Couldn't delete from hash"
    #end
    #puts "Person is no longer connected"
  end
  
end