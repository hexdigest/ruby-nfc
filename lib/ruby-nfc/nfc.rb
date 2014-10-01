require 'ffi'
require 'logger'
require_relative './libnfc'

module NFC
  class Error < ::Exception;end

  @@context = nil
  # TODO
  @@logger = Logger.new(STDERR)

  def self.version
    LibNFC.nfc_version
  end

  def self.context
    unless @@context
      ptr = FFI::MemoryPointer.new(:pointer, 1)
      LibNFC.nfc_init(ptr)
      @@context = ptr.read_pointer
    end
  end

  def self.logger
  	@@logger
  end
end
