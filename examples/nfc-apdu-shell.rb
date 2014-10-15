require 'ruby-nfc'

WAITING_FOR_TAG = "Waiting for tag..."
PROMPT = "%s < "
OUTPUT = "%s > %s"

puts WAITING_FOR_TAG

NFC::Reader.all[0].poll(IsoDep::Tag) do |tag|
  begin
  	loop do
			print PROMPT % uid_hex
			apdu = $stdin.readline.gsub(/\s+/, '')
			case apdu
			when /exit|quit/
				puts "Bye!"
				exit!
			when /^([a-f0-9]{2}){5,128}$/i
				response = send_apdu [apdu].pack('H*')
				puts OUTPUT % [uid_hex, response]
			else
				puts "Error: wrong APDU format"
			end
		end
  rescue Exception => e
    p e
		puts WAITING_FOR_TAG
  end
end
