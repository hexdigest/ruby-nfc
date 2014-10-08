module NFC
	class Reader
  	attr_reader :ptr

    def initialize(device_name)
      @name = device_name
      @ptr = nil
    end

    def set_flag(name, value)
			LibNFC.nfc_device_set_property_bool(@ptr, name, value)
    end

    def connect
      @ptr ||= LibNFC.nfc_open(NFC.context, @name)
      raise NFC::Error.new('Cant connect to ' << @name) if @ptr.null?
      self
    end

    # Returns list of tags applied to reader
    def discover(*card_types)
      # TODO: по правильному здесь надо делать низкоуровневый
      card_types.inject([]) do |tags, card_type|
        raise NFC::Error.new('Wrong card type') unless card_type.respond_to? :discover
        tags += card_type.discover(connect)
      end
    end

    def poll(*card_types, &block)
    	connect

			LibNFC.nfc_initiator_init(@ptr) # we'll be initiator not a target

      set_flag(:NP_ACTIVATE_FIELD, false)
 			set_flag(:NP_HANDLE_CRC, true)
 			set_flag(:NP_HANDLE_PARITY, true)
     	set_flag(:NP_AUTO_ISO14443_4, true)
 			set_flag(:NP_ACTIVATE_FIELD, true)

      modulation = LibNFC::Modulation.new
			modulation[:nmt] = :NMT_ISO14443A 
			modulation[:nbr] = :NBR_106

      targets = FFI::MemoryPointer.new(:uchar, LibNFC::Target.size * 10)

			loop do
   			res = LibNFC.nfc_initiator_list_passive_targets(@ptr, modulation, 
   																											targets, 10)
			
				# iterate over all applied targets and iterate
				0.upto(res - 1) do |i|
					target = LibNFC::Target.new(targets + i * LibNFC::Target.size)
					# iterate over requested card types for each target
					# notice that some targets can match several types i.e.
					# contactless credit cards (PayPass/payWave) with mifare chip
					# on board
					card_types.each do |card_type|
						if card_type.match?(target)
							tag = card_type.new(target, self)
							tag.connect(&block)
							# if this tag was marked as processed - continue with next tag
							break if target.processed?
						end
					end
				end # upto
			end # loop
    end

    def to_s
      @name
    end

    def self.all
      ptr = FFI::MemoryPointer.new(:char, 1024 * 10)
      len = LibNFC.nfc_list_devices(NFC.context, ptr, 10)

      if len <= 0
        raise NFC::Error, "No compatible NFC readers found"
      else
        names = ptr.get_bytes(0, 1024 * len).split("\x00").reject {|e| e.empty?}
        names.map {|name| Reader.new(name)}
      end 
    end
	end
end
