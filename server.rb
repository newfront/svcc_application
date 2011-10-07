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
  'json',
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
  
end