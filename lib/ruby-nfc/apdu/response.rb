module APDU
	class Response
		def initialize(response)
			@response = response
		end

		# Public: Parse response without checking SW
		def parse

		end

		# Public: Parse APDU response and check SW after. 
		#
		# Returns instance of APDU::Response class
		# Raises APDU::Errno if SW != 9000
		def parse!

		end

		# Public: Return Status Word of an APDU response. Status Word is a two-byte
		# result code
		def sw
			@response[-2, 2].unpack('n').pop
		end

		# Public: Return high byte of Status Word aka SW1
		def sw1
			@response[-2, 1].unpack('C').pop
		end

		# Public: Return low byte of Status Word aka SW2
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
