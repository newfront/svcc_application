# Message module stores the logic for generating messages for pub/sub
module Message
  # format a new message
  # message is a String to send
  # params is a hash that stores the 1. type, 2. response code [200,400]
  def self.format(message,params={})
    # message format
    # {'message':{'code':200,'type':'default','text':''}}
    
    # is message empty?
    unless !message.nil?
      unless !message.is_a? String
        # force message to be string
        message = message.to_s
      end
      message = message.gsub(/[^A-Z0-9_-]/i,'')
    end
    
    # create a new message template
    begin
      m = Hashie::Mash.new
      m.code = !params[:code].nil? ? params[:code] : 200
      m.type = !params[:type].nil? ? params[:type] : 'default'
      m.text = !message.nil? ? message.to_s.strip : 'text undefined'
      return m.to_json
    rescue ArgumentError => e
      puts e.to_s
    end
    
    # return m as json
    return format("argument error: #{e}",{:code => 400, :type => "error"})
  end
  
  # parse a message and return json
  def self.parse(blob)
    text = ''
    
    # strip slashes
    blob = blob.gsub(/\\+\\/,'')
    
    # failover if not JSON formatted, and create message object
    begin
      text = JSON.parse(blob)
    rescue JSON::ParserError => e
      # is the data less than the maximum bytesize set forth by the server config
      unless blob.bytesize > $conf.server.application.rawdata.max_byte_size
        text = JSON.parse(self.format(blob,{:code => 200, :type => 'message'}))
      end
    end
    return text
  end
  
end