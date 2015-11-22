module NFC
	class Tag
		def initialize(target, reader)
			@target = target
			@reader = reader
			@processed = false
		end

		def connect(&block)
			if block_given?
				begin
					self.instance_eval(&block)
				ensure
					disconnect
				end
			end
		end

		def processed!
			@target.processed!
		end

		def processed?
			@target.processed?
		end

    def present?
      modulation = LibNFC::Modulation.new
			modulation[:nmt] = :NMT_ISO14443A 
			modulation[:nbr] = :NBR_106

      ptr = FFI::MemoryPointer.new(:char, @target[:nti][:nai][:szUidLen])
      ptr.put_bytes(0, uid)

	    res = LibNFC.nfc_initiator_select_passive_target(@reader.ptr, modulation, ptr,
	                                                     @target[:nti][:nai][:szUidLen],
	                                                     FFI::Pointer::NULL)

	    return res >= 1
    end

		def disconnect; end

		def uid
			uid_size = @target[:nti][:nai][:szUidLen]
			@target[:nti][:nai][:abtUid].to_s[0...uid_size]
		end

		def uid_hex
			uid.unpack('H*').pop
		end

		def to_s
			uid_hex
		end

		# Matches any NFC tag
		def self.match?(target)
			true
		end

	end
end
