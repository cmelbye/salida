module Salida
  module BitcoinConnection
    def post_init
      send_message Messages::Version.new(:addr_you => Messages::NetworkAddress.new(:addr => "127.0.0.1", :port => 8333))
    end
    
    def send_message message
      send_data message.pack
    end
    
    def receive_data data
      command = data.unpack("La12")[1].strip
      p Messages.const_get(command.capitalize).new_from_binary(data)
    end
  end
end