module Channels

  # create a channel and bind it to the global channels object
  def self.create_channel(name,type="public")
    unless $channels.has_key? name.to_sym
      # create a channel
      channel = Channel.new({:name => name, :type => type})
      puts channel.inspect
      $channels.store(name.to_sym,Channel.new({:name => name, :type => type}))
      return "channel created"
    else
      return "channel exists"
    end
  end

end