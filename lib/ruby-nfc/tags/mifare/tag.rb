require 'ffi'
require_relative '../../nfc'
require_relative '../tag'

module Mifare
	class Error < Exception; end

  extend FFI::Library

  ffi_lib ['libfreefare', 'libfreefare.so', '/usr/local/lib/libfreefare.so']

	# List of known mifare card's SAKs	
	SAKS = {
		CLASSIC_1K: 0x08,
		CLASSIC_1K_EMULATED: 0x28,
		CLASSIC_1K_ANDROID: 0x68, # Android with mifare emulated by USIM or eSE
		INFINEON_CLASSIC_1k: 0x88,
		CLASSIC_4K: 0x18,
		CLASSIC_4K_EMULATED: 0x38,
		ULTRALIGHT: 0x00
	}

  # common freefare functions prototypes
	attach_function :freefare_tag_new, [:pointer, LibNFC::Target.by_value], :pointer
	attach_function :freefare_free_tag, [:pointer], :void

  # tag
  attach_function :freefare_get_tag_uid, [:pointer], :string
  # tag
  attach_function :freefare_get_tag_friendly_name, [:pointer], :string

  # device, pointer to array of pointers to tags
  # and we need to go deeper :)
  attach_function :freefare_get_tags, [:pointer], :pointer

	class Tag < NFC::Tag
		def initialize(target, reader)
			super(target, reader)

			@pointer = Mifare.freefare_tag_new(reader.ptr, target)

			raise Mifare::Error, "Unknown mifare tag" if @pointer.null?
		end

		def name
			Mifare.freefare_get_tag_friendly_name(@pointer)
		end

		def to_s
			"#{uid_hex} #{name} SAK: 0x#{@target.sak.to_s(16)}"
		end

		# frees memory allocated for mifare tag
		def disconnect
			Mifare.freefare_free_tag(@pointer)
		end

		def sak
			target.sak
		end

		def self.match?(target)
			SAKS.values.include?(target[:nti][:nai][:btSak])
		end

	end
end

