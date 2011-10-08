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