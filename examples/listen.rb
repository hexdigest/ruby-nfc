require 'ruby-nfc'

puts "Library version: %s" % NFC.version
readers = NFC::Reader.all
puts "Available readers: %s" % readers.to_s

# The order of tag types in poll arguments defines priority of tag types
readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag) do |tag|
  begin
  	puts "Applied #{tag.class.name}: #{tag}"

		case tag
		when Mifare::Classic::Tag
			# Perform authentication to block 0x04 with the Key A that equals 
			# to "\xFF\xFF\xFF\xFF\xFF\xFF" you can also use "FFFFFFFFFFFF"
			# representation. In this case it will be automatically packed to 6 bytes
			if auth(4, :key_a, "FFFFFFFFFFFF")
				puts "authenticated!"
				processed! # mark tag as processed so even if it supports different
									 # protocol poll method will continue with another physical
									 # tag
			end
  	when Mifare::Ultralight::Tag
			puts "Page 1: %s" % read(1).unpack('H*').pop
			processed!
		when IsoDep::Tag
			select ["F75246544101"].pack('H*')
			# sending APDU command to tag using send_apdu method
			apdu = ['A00D010018B455CAF0F331AF703EFA2E2D744EC7E22AA64076CD19F6D0'].pack('H*')
			puts send_apdu(apdu).unpack('H*').pop

			# sending APDU command with "<<" operator which is alias to send_apdu
			# response = tag << apdu
			# puts response.unpack('H*').pop
			processed!
		end
  rescue Exception => e
    puts e
  end
end
