require_relative './apdu'

module APDU
	class Request
		attr_accessor :cla, :ins, :p1, :p2, :lc, :data, :le

		def self.from_string(apdu)
			raise APDU::Error, "APDU is too short: #{apdu.size}" if apdu.size < 5

			apdu_8bit = apdu.dup
			apdu_8bit.force_encoding('ASCII-8BIT')
			
		  req = self.new
		  req.cla, req.ins, req.p1, req.p2, req.lc, req.data = apdu.unpack('CCCCCA*')

		  if req.data.size == req.lc
		    req.le = 0
		  elsif req.data.size == req.lc + 1
		    req.le = req.data[-1,1].ord
		    req.data = req.data[0...-1]
		  else
		    raise APDU::Error, "Wrong Lc or wrong command data length"
		  end

      req
		end

		def self.from_hex_string(apdu)
		  raise APDU::Error, "Wrong format" if apdu !~ /^([a-fA-F0-9]{2}){5,128}$/
      from_string([apdu].pack('H*'))
		end

    # Public: Build APDU command
		def build
      [self.to_s].pack('H*')
		end

		def to_s
      [cla, ins, p1, p2, lc, data, le].pack('CCCCCA*C').unpack('H*').pop.upcase
		end
	end
end
