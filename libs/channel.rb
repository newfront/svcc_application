class Channel
  
  attr_accessor :id, :name, :type, :open
  
  # auto-setup channel properties
  def initialize(params={})
    self.id = self.get_id
    self.name = !params[:name].nil? ? params[:name] : "default"
    self.type = !params[:type].nil? ? params[:type] : "public"
    self.open = true
  end
  
  # create channel counter
  # use static class variable to hold the counter (@@)
  def get_id
    (@@id ||= 1)
    tmp = @@id
    @@id += 1
    return tmp
  end
  
  def close_channel
    self.open = false
    # dispatch message, channel closed
  end
  
end