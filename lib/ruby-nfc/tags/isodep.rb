require_relative '../nfc'
require_relative './tag'

module IsoDep
	ISO_14443_4_COMPATIBLE = 0x20

	class Error < ::Exception; end

	class Tag < NFC::Tag

		def self.match?(target)
			target[:nti][:nai][:btSak] & IsoDep::ISO_14443_4_COMPATIBLE > 0
		end

    def select(aid = nil, &block)
     	@reader.set_flag(:NP_AUTO_ISO14443_4, true)

			modulation = LibNFC::Modulation.new
			modulation[:nmt] = :NMT_ISO14443A
			modulation[:nbr] = :NBR_106

			nai_ptr = @target[:nti][:nai].pointer

			# abt + sak + szUidLen offset
			uid_ptr = nai_ptr + FFI.type_size(:uint8) * 3 + FFI.type_size(:size_t)

			res = LibNFC.nfc_initiator_select_passive_target(
				@reader.ptr,
				modulation,
				uid_ptr,
				uid.length,
				@target.pointer
			)

			if res > 0
				# trying to select applet if applet identifier was given
				if aid
					sw = send_apdu("\x00\xA4\x04\x00#{aid.size.chr}#{aid}")
					raise IsoDep::Error, "Application not found: #{aid.unpack('H*').pop}" unless "\x90\x00" == sw
				end

				super(&block)
			else
				raise IsoDep::Error, "Can't select tag: #{res}"
			end
    end

    def deselect
			0 == LibNFC.nfc_initiator_deselect_target(@reader.ptr)
    end

    def send_apdu(apdu)
    	cmd = apdu
    	cmd.force_encoding('ASCII-8BIT')
			command_buffer = FFI::MemoryPointer.new(:uint8, cmd.length)
			command_buffer.write_string_length(cmd, cmd.length)

			response_buffer = FFI::MemoryPointer.new(:uint8, 254)

			res_len = LibNFC.nfc_initiator_transceive_bytes(@reader.ptr,
				command_buffer, cmd.length, response_buffer, 254, 0)

			raise IsoDep::Error, "APDU sending failed: #{res_len}" if res_len < 0

			response_buffer.get_bytes(0, res_len).to_s
    end

    alias :'<<' :send_apdu
	end

end
