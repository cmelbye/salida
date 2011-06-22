module Salida
  module Messages
    class NetworkAddress < Message
      field :services,  pack: "Q", default: 1
      
      field :addr,      pack: proc { |value|
          [0, 0, 4294901760, IPAddr.new(value, Socket::AF_INET).to_i].pack("NNNN")
        }, unpack: proc { |value|
          IPAddr.new(value.unpack("NNNN")[3], Socket::AF_INET)
        }, length: 16
      
      field :port,      pack: "n", default: 8333
      
      def self.length
        26
      end
      
      def self.local_address
        self.new(:addr => self.local_ip)
      end

      def self.local_ip
        orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

        UDPSocket.open do |s|
          s.connect '64.233.187.99', 1
          s.addr.last
        end
      ensure
        Socket.do_not_reverse_lookup = orig
      end
    end
  end
end