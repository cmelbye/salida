require 'rubygems'
require 'eventmachine'
require 'socket'
require 'ipaddr'

require 'salida/runner'
require 'salida/bitcoin_connection'

require 'salida/message'
require 'salida/messages/network_address'
require 'salida/messages/version'

module Salida
  VERSION = 0.1
  NETWORK = "\xF9\xBE\xB4\xD9"
  NONCE = rand(2**64)
end