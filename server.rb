#!/usr/bin/env ruby

# update global path (fix for local paths in ruby 1.9)
$: << File.join(File.dirname(__FILE__), "")
$: << $APP_ROOT = File.expand_path(File.dirname(__FILE__))

# grab dependencies
# 'mechanize'
requires = [
  'em-websocket',
  'cgi','em-http-request',
  'sinatra/base',
  'thin',
  'logger',
  'yaml',
  'hashie',
  'socket',
  'pp',
  'json'
  ]
requires.each {|dependency| require dependency}

$conf = Hashie::Mash.new
$conf.server = Hashie::Mash.new(YAML.load_file(File.join($APP_ROOT,'config','server.yml')))

puts "CONFIG?: #{$conf.server.inspect}"

class Conductor < EventMachine::Connection
  
  def initialize(*args)
    ($connections ||= Hashie::Mash.new)
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
    puts pp.inspect
    begin
      @info = Hashie::Mash.new(JSON.parse(data))
    rescue
      puts "couldn't parse JSON"
      return
    end
    
    # Event Dispatcher
    dispatch_event(@info)
    
  end
  
  # read packet params and respond accordingly
  def dispatch_event(data)
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
    puts "connection #{self.id.to_s} unbound"
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

EventMachine.run do
  
  # run main event-server
  begin
    EventMachine::start_server('0.0.0.0',$conf.server.application.port,Conductor)
    puts "Running Server on port #{$conf.server.application.port.to_s}"
  rescue ArgumentError => e
    rasie e
  end
  
end