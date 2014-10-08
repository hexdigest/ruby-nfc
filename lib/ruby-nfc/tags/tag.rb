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
