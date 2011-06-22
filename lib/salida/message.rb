module Salida
  class Message
    class << self
      def field(name, options={})
        fields[name] = options
      end

      def fields
        @fields ||= {}
      end

      def header(options={})
        @header_options = options
      end

      def header_options
        @header_options ||= false
      end
      
      def new_from_binary(full_binary_string)
        new_fields = {}
        
        if self.header_options
          if self.header_options[:skip_checksum]
            header_unpack_string = "La12L"
            network, command, payload_length = full_binary_string.unpack(header_unpack_string)
            header_length = 20
          else
            header_unpack_string = "La12LL"
            network, command, payload_length, checksum = full_binary_string.unpack(header_unpack_string)
            header_length = 24
          end
          header, binary_string = full_binary_string.unpack("a#{header_length}a#{payload_length}")
        else
          binary_string = full_binary_string
        end
        
        unpack_string = ""
        self.fields.each do |k, opts|
          if opts[:pack].is_a?(String)
            unpack_string << opts[:pack]
          else
            if opts[:length]
              unpack_string << "a#{opts[:length]}"
            elsif opts[:embed]
              unpack_string << "a#{opts[:embed].length}"
            else
              fail "Could not determine unpack string"
            end
          end
        end
        
        field_parts = binary_string.unpack(unpack_string)
        index = 0
        
        self.fields.each do |k, opts|
          if opts[:pack].is_a?(String) # it's already unpacked
            new_fields[k] = field_parts[index]
          elsif opts[:unpack].is_a?(Proc)
            new_fields[k] = opts[:unpack].call(field_parts[index])
          elsif opts[:embed]
            new_fields[k] = opts[:embed].new_from_binary(field_parts[index])
          else
            fail "Could not unpack"
          end
          index += 1
        end
        
        self.new(new_fields)
      end
    end

    attr_accessor :field_values

    def initialize(options={})
      @field_values = {}

      self.class.fields.each do |k, opts|
        @field_values[k] = options[k] || opts[:default]
      end
    end
    
    def method_missing(method, *args, &block)
      if self.field_values[method]
        self.field_values[method]
      else
        super
      end
    end

    def pack
      message_payload = ""
      self.class.fields.each do |k,opts|
        field_value = self.field_values[k].is_a?(Proc) ?
          self.field_values[k].call : self.field_values[k]

        if opts[:pack].is_a?(String)
          message_payload << [field_value].pack(opts[:pack])
        elsif opts[:pack].is_a?(Proc)
          message_payload << opts[:pack].call(field_value)
        elsif opts[:pack].nil? # We assume that the value can pack itself
          message_payload << field_value.pack
        end
      end

      message_header = ""
      if self.class.header_options
        header_parts = [Salida::NETWORK, self.class.header_options[:command], message_payload.length]
        pack_string = "a4a12L"

        unless self.class.header_options[:skip_checksum]
          #header_parts << the_checksum
          #pack_string << "L"
        end

        message_header += header_parts.pack(pack_string)
      end

      message_header + message_payload
    end
  end
end