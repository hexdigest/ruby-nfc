require 'ruby-nfc'
require 'logger'

$logger = Logger.new(STDOUT)

def p(str)
	$logger.debug str
end

p "Library version: #{NFC.version}"
readers = NFC::Reader.all
p "Available readers: #{readers}"

# The order of tag types in poll arguments defines priority of tag types
readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag) do |tag|
	begin
		p "Applied #{tag.class.name}: #{tag}"

		case tag
		when Mifare::Classic::Tag
			if tag.auth(4, :key_a, "FFFFFFFFFFFF")
				# Mifare::Classic::Tag.read method reads contents of last authenticated
				# block
				p "Contents of block 0x04: #{tag.read.unpack('H*').pop}"
				# Making random 16-byte string
				rnd = Array.new(16).map{rand(255)}.pack('C*')
				tag.write(rnd)
				p "New value: #{rnd.unpack('H*').pop}"
				tag.processed!
			else
				p "Authentication failed!"
			end
		when Mifare::Ultralight::Tag
			p "Page 1: #{tag.read(1).unpack('H*').pop}"
			tag.processed!
		when IsoDep::Tag
			tag.select! ["F75246544101"].pack('H*')
			# sending APDU command to tag using send_apdu method
			apdu = ['A00D010018B455CAF0F331AF703EFA2E2D744EC7E22AA64076CD19F6D0'].pack('H*')
			p tag.send_apdu(apdu)

			# sending APDU command with "<<" operator which is alias to send_apdu
			response = tag << apdu
			p "status word: #{response.sw.to_s(16)} data: #{response.data.unpack('H*').pop}"
			tag.processed!
		end

	rescue Exception => e
		p e
	end
end