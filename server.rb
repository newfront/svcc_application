#!/usr/bin/env ruby

# update global path (fix for local paths in ruby 1.9)
$: << File.join(File.dirname(__FILE__), "")
$: << $APP_ROOT = File.expand_path(File.dirname(__FILE__))

# grab dependencies
# 'mechanize'
requires = [
  'em-websocket',
  'cgi',
  'em-http-request',
  'sinatra/async',
  'thin',
  'logger',
  'yaml',
  'hashie',
  'socket',
  'pp',
  'json',
  'digest/md5',
  'libs/conductor',
  'libs/message',
  'libs/channels',
  'libs/channel',
  'libs/conductor_handler'
  ]
requires.each {|dependency| require dependency}

# main configuration hash
$conf = Hashie::Mash.new
# server configuration
$conf.server = Hashie::Mash.new(YAML.load_file(File.join($APP_ROOT,'config','server.yml')))

#puts "CONFIG?: #{$conf.server.inspect}"

# Note: Thin Server runs its own EventMachine loop
# if your not using thin, you sometimes have tear down issues...
EventMachine.run do
  
  # stores connections
  ($connections ||= {})
  
  # stores the channels
  ($channels ||= Hashie::Mash.new)
  
  # create channel
  mchannel = Channels::create_channel("main","public")
  puts mchannel
  puts $channels.inspect
  
  # run main event-server
  begin
    EventMachine::start_server('0.0.0.0',$conf.server.application.eventmachine.port,Conductor)
    puts "Running Server on port #{$conf.server.application.eventmachine.port.to_s}"
  rescue ArgumentError => e
    raise e
  end
  
  # setup some callbacks
  $ws_notifier = EventMachine.Callback{|msg|
    puts (msg) 
    puts $ws_connections.size.to_s
    unless $ws_connections.size == 0
      $ws_connections.each {|connection|
        #puts connection.inspect
        #connection[0] = user uuid
        #connection[1] = user web socket object
        connection[1].send(msg)
      }
    end
  }
  
  # setup web socket connections ( in memory )
  ($ws_connections ||= {})
  
  # web socket server
  EventMachine::WebSocket.start(:host => $conf.server.application.websocket.host, :port => $conf.server.application.websocket.port) do |ws|
    
    # same as initialize / post_init
    ws.onopen {
      puts "WebSocket connection open"
      # publish message to the client
      @user = ws
      
      
      
      connection = Hashie::Mash.new
      connection.uuid = Digest::MD5.hexdigest((Time.now).to_s + Random.rand(999999).to_s)
      connection.first_name = "Temp"
      connection.last_name = "User"
      connection.auth_key = $conf.server.application.connection.auth_key
      connection.type = "register"
      
      # send connection details back to user ( what is their uuid )
      ws.send(Message::format(connection.uuid,{:code=>200,:type=>"uuid"}))
      
      # connect the websocket to a traditional socket
      @em = EventMachine::connect('127.0.0.1',5000, ConductorHandler, connection)
      
      $ws_connections.store(connection.uuid,ws)
      ws.send(Message::format("registering",{:code=>200,:type=>"message"}))
    }
    # same as unbind
    ws.onclose { 
      puts "Connection closed" 
      $ws_connections.delete(ws)
    }
    # same as receive data
    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
      puts msg.inspect
      #ws.send "#{msg}"
    }
  end
  
  # setup the sinatra web server
  class SVCCAPP < Sinatra::Base
    register Sinatra::Async
    #set :port => $conf.server.application.port
    #set :host => 'localhost'
    set :environment, :development
    set :loggin, true
    set :sessions, true
    set :dump_errors, true
    set :public_folder => 'public/'
    
    # homepage 
    # allows you to join an irc channel ( main by default )
    get '/' do
      @title = "SVCC IRC/Chat"
      @year = Time.new.year
      erb :index
    end
    
    # path for the irc module 
    get '/realtime/irc' do
      @title = "SVCC WS-IRC Channel"
      @year = Time.new.year
      erb "irc/index".to_sym
    end
    
  end

  # if not using rackup middleware
  SVCCAPP.run!({:port => $conf.server.application.port})
end