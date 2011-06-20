module Salida
  module BitcoinConnection
    def post_init
      p get_peername
      @port, @addr = Socket.unpack_sockaddr_in(get_peername)
      send_message Messages::Version.new(:addr_you => Messages::NetworkAddress.new(:addr => @addr, :port => @port))
    end
    
    def send_message message
      p message
      send_data message.pack
    end
    
    def receive_data data
      Message.
      p data.unpack("La12")[1].strip
    end
  end
end