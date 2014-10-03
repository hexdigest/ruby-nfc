module APDU 
  class Error < ::Exception; end

	class Errno < ::Exception
		STATUS_STRINGS = {
			#0x6XXX => "Transmission protocol related codes                                                                          
			#0x61XX => "SW2 indicates the number of response bytes still available",

			0x6200 => "No information given",
			0x6281 => "Returned data may be corrupted",
			0x6282 => "The end of the file has been reached before the end of reading",
			0x6283 => "Invalid DF",
			0x6284 => "Selected file is not valid. File descriptor error",

			0x6300 => "Authentification failed. Invalid secret code or forbidden value",
			0x6381 => "File filled up by the last write",
#			0x63CX => "Counter provided by 'X' (valued from 0 to 15) (exact meaning depending on the command)",

			0x6501 => "Memory failure. There have been problems in writing or reading the EEPROM\n" +
								"Other hardware problems may also bring this error.",
			0x6581 => "Write problem / Memory failure / Unknown mode",

#			0x67XX => "Error, incorrect parameter P3 (ISO code)",
			0x6700 => "Incorrect length or address range error",

			0x6800 => "The request function is not supported by the card.",
			0x6881 => "Logical channel not supported",
			0x6882 => "Secure messaging not supported",

			0x6900 => "No successful transaction executed during session",
			0x6981 => "Cannot select indicated file, command not compatible with file organization",
			0x6982 => "Access conditions not fulfilled",
			0x6983 => "Secret code locked",
			0x6984 => "Referenced data invalidated",
			0x6985 => "No currently selected EF, no command to monitor / no Transaction Manager File",
			0x6986 => "Command not allowed (no current EF)",
			0x6987 => "Expected SM data objects missing",
			0x6988 => "SM data objects incorrect",

			0x6A00 => "Bytes P1 and/or P2 are incorrect.",
			0x6A80 => "The parameters in the data field are incorrect",
			0x6A81 => "Card is blocked or command not supported",
			0x6A82 => "File not found",
			0x6A83 => "Record not found",
			0x6A84 => "There is insufficient memory space in record or file",
			0x6A85 => "Lc inconsistent with TLV structure",
			0x6A86 => "Incorrect parameters P1P2",
			0x6A87 => "The P3 value is not consistent with the P1 and P2 values.",
			0x6A88 => "Referenced data not found.",

			0x6B00 => "Incorrect reference; illegal address; Invalid P1 or P2 parameter",

#			0x6CXX => "Incorrect P3 length.",

			0x6D00 => "Command not allowed. Invalid instruction byte (INS)",

			0x6E00 => "Incorrect application (CLA parameter of a command)",

			0x6F00 => "Checking error",

			0x9000 => "Command executed without error",

			0x9100 => "Purse Balance error cannot perform transaction",
			0x9102 => "Purse Balance error",

#			0x92XX => "Memory error",
			0x9202 => "Write problem / Memory failure",
			0x9240 => "Error, memory problem",

#			0x94XX => "File error",
			0x9404 => "Purse selection error or invalid purse",
			0x9406 => "Invalid purse detected during the replacement debit step",
			0x9408 => "Key file selection error",

#			0x98XX => "Security error",
			0x9800 => "Warning",
			0x9804 => "Access authorization not fulfilled",
			0x9806 => "Access authorization in Debit not fulfilled for the replacement debit step",
			0x9820 => "No temporary transaction key established",
			0x9834 => "Error, Update SSD order sequence not respected"
		}

		attr_accessor :code

		def initialize(sw)
			@code = sw
			message = STATUS_STRINGS[sw] || "Unknown error"

			super("#{sw.to_s(16)} #{message}")
		end
	end
end
