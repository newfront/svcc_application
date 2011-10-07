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
  'sinatra/base',
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
  'libs/channel'
  ]
requires.each {|dependency| require dependency}

# main configuration hash
$conf = Hashie::Mash.new
# server configuration
$conf.server = Hashie::Mash.new(YAML.load_file(File.join($APP_ROOT,'config','server.yml')))

#puts "CONFIG?: #{$conf.server.inspect}"

EventMachine.run do
  
  # build some channels
  # stores the channels
  ($channels ||= Hashie::Mash.new)
  
  # create channel
  mchannel = Channels::create_channel("main","public")
  puts mchannel
  puts $channels.inspect
  
  # run main event-server
  begin
    EventMachine::start_server('0.0.0.0',$conf.server.application.port,Conductor)
    puts "Running Server on port #{$conf.server.application.port.to_s}"
  rescue ArgumentError => e
    rasie e
  end
  
  # setup web socket connections ( in memory )
  ($ws_connections ||= {})
  
  # setup some callbacks
  $new_messages = EventMachine.Callback{|msg|
    puts (msg) 
    puts $ws_connections.size.to_s
    unless $ws_connections.size == 0
      $ws_connections.each {|connection|
        connection.send(msg)
      }
    end
  }
  
  # web socket server
  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => $conf.server.application.websocket.port) do |ws|
    
    # same as initialize / post_init
    ws.onopen {
      puts "WebSocket connection open"
      # publish message to the client
      ws.send "connected"
      @user = ws
      $ws_connections << ws
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
  
end