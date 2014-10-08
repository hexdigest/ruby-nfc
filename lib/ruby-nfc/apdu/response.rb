require_relative './apdu'

module APDU
	class Response
		def initialize(response)
			resp_8bit = response.dup
			resp_8bit.force_encoding('ASCII-8BIT')

			raise APDU::Error, "Response must be at least 2-bytes long" if resp_8bit.size < 2

			@response = resp_8bit
		end

		# Public: Raises APDU::Errno if self.sw is not equal 0x9000
		def raise_errno!
			raise APDU::Errno.new(sw) if sw != 0x9000
			self
		end

		# Public: Return Status Word of an APDU response. Status Word is a two-byte
		# result code
		def sw
			@response[-2, 2].unpack('n').pop
		end

		# Public: Return high byte of Status Word
		def sw1
			@response[-2, 1].unpack('C').pop
		end

		# Public: Return low byte of Status Word
		def sw2
			@response[-1,1].unpack('C').pop
		end

		def data
			@response[0...-2]
		end

		def to_s
			@response.unpack('H*').pop
		end

		def [](index)
			@response[index]
		end
	end
end
