module Salida
  module Messages
    class Version < Message
      header command: "version", skip_checksum: true

      field :version,   pack: "L",  default: 32100
      field :services,  pack: "Q",  default: 1
      field :timestamp, pack: "Q",  default: -> { Time.now.to_i }
      field :addr_me,               default: -> { Salida::Messages::NetworkAddress.local_address }
      field :addr_you
      field :nonce,     pack: "Q",  default: -> { Salida::NONCE }
      field :subver,    pack: "a1", default: ""
    end
  end
end