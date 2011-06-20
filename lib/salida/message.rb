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
    end

    attr_accessor :field_values

    def initialize(options={})
      @field_values = {}

      self.class.fields.each do |k, opts|
        @field_values[k] = options[k] || opts[:default]
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