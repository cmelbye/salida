require 'optparse'

module Salida
  class Runner
    attr_accessor :options, :arguments
    
    def initialize(argv)
      @argv = argv
      
      @options = {}
      
      parse!
    end
    
    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: salida [options]"
        
        opts.separator ""
        opts.separator "Other options:"

        opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
        opts.on_tail('-v', '--version', "Show version") { puts "Salida #{Salida::VERSION}"; exit }
      end
    end
    
    def parse!
      parser.parse! @argv
      @arguments = @argv
    end
    
    def run!
      puts "Salida #{Salida::VERSION}"
      puts
      
      EM.run do
        EM.connect "207.192.69.206", 8333, Salida::BitcoinConnection
      end
    end
  end
end