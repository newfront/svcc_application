requires = [
  'eventmachine',
  'hashie',
  'socket',
  'pp',
  'json',
  'digest/md5'
  ]
requires.each {|dependency| require dependency}

# Base Connection class for each individual client

class ConductorHandler < EventMachine::Connection
  
  # Prepare User Object to send to main EventMachine server
  def initialize(*args)
    super
    @user = args
  end
  
  # socket is now bound
  def post_init
    puts @user.inspect
    send_data(@user[0].to_json)
  end
  
  # new data available on socket
  def receive_data(data)
    puts data
  end
  
  # socket closed
  def unbind
    puts "server disconnected you"
  end
  
end

connection = Hashie::Mash.new
connection.uuid = Digest::MD5.hexdigest((Time.now).to_s + Random.rand(999999).to_s)
connection.first_name = "Scott"
connection.last_name = "Haines"
connection.software_key = "99-0-KK-9453-8322"
connection.type = "register"

EventMachine.run do
  @em = EventMachine::connect('127.0.0.1',5000, ConductorHandler, connection)
end