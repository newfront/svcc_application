#!/usr/bin/env ruby

require 'eventmachine'
require 'json'
require 'pp'

@port = 7000

module CocoaEchoServer
  
  def post_init
    puts "connection established"
    @connection_id = self.object_id
  end
  
  def receive_data(data)
    
    puts "data received on connection #{@connection_id.inspect}"
    pp data
    
    # echo back to Cocoa or some other bound socket connection
    send_data("got it #{data.to_s}")
    
  end
  
  def unbind
  end
  
end

EventMachine.run do
  puts "EventMachine Server started on port #{@port.to_s}"
  EventMachine::start_server('0.0.0.0',@port,CocoaEchoServer)
end