require 'ffi'

module LibNFC
  extend FFI::Library
  ffi_lib ['libnfc', 'libnfc.so', 'libnfc.so.5', '/usr/local/lib/libnfc.so']

  PROPERTIES = [ # please refer to nfc-types.h for description
  	:NP_TIMEOUT_COMMAND,
  	:NP_TIMEOUT_ATR,
  	:NP_TIMEOUT_COM,
  	:NP_HANDLE_CRC,
  	:NP_HANDLE_PARITY,
  	:NP_ACTIVATE_FIELD,
  	:NP_ACTIVATE_CRYPTO1,
  	:NP_INFINITE_SELECT,
  	:NP_ACCEPT_INVALID_FRAMES,
  	:NP_ACCEPT_MULTIPLE_FRAMES,
  	:NP_AUTO_ISO14443_4,
  	:NP_EASY_FRAMING,
  	:NP_FORCE_ISO14443_A,
  	:NP_FORCE_ISO14443_B,
  	:NP_FORCE_SPEED_106
  ]

  DEP_MODE = [
    :NDM_UNDEFINED,
    :NDM_PASSIVE,
    :NDM_ACTIVE
  ]

  BAUD_RATE = [
    :NBR_UNDEFINED,
    :NBR_106,
    :NBR_212,
    :NBR_424,
    :NBR_847
  ]

  MODULATION_TYPE = [
    :NMT_ISO14443A, 1,
    :NMT_JEWEL,
    :NMT_ISO14443B,
    :NMT_ISO14443BI, # pre-ISO14443B aka ISO/IEC 14443 B' or Type B'
    :NMT_ISO14443B2SR, # ISO14443-2B ST SRx
    :NMT_ISO14443B2CT, # ISO14443-2B ASK CTx
    :NMT_FELICA,
    :NMT_DEP
  ]

  class ISO14443a < FFI::Struct
  	pack 1
    layout(
      :abtAtqa, [:uint8, 2],
      :btSak, :uint8,
      :szUidLen, :size_t,
      :abtUid, [:uint8, 10],
      :szAtsLen, :size_t,
      :abtAts, [:uint8, 254]
    )
  end

  class Felica < FFI::Struct
  	pack 1
    layout(
      :szLen, :size_t,
      :btResCode, :uint8,
      :abtId, [:uint8, 8],
      :abtPad, [:uint8, 8],
      :abtSysCode, [:uint8, 2]
    )
  end

  class ISO14443b < FFI::Struct
  	pack 1
    layout(
      :abtPupi, [:uint8, 4],
      :abtApplicationData, [:uint8, 4],
      :abtProtocolInfo, [:uint8, 3],
      :ui8CardIdentifier, :uint8
    )
  end

  class ISO14443bi < FFI::Struct
  	pack 1
    layout(
      :abtDIV, [:uint8, 4],
      :btVerLog, :uint8,
      :btConfig, :uint8,
      :szAtrLen, :size_t,
      :abtAtr, [:uint8, 33]
    )
  end

  class ISO14443b2sr < FFI::Struct
  	pack 1
    layout(
      :abtUID, [:uint8, 8]
    )
  end

  class ISO14443b2ct < FFI::Struct
  	pack 1
    layout(
      :abtUID, [:uint8, 4],
      :btProdCode, :uint8,
      :btFabCode, :uint8
    )
  end

  class Jewel < FFI::Struct
  	pack 1
    layout(
      :btSensRes, [:uint8, 2],
      :btId, [:uint8, 4]
    )
  end

  DepEnum = enum(DEP_MODE)

  class DepInfo < FFI::Struct
  	pack 1
    layout(
      :abtNFCID3, [:uint8, 10],#     uint8_t  abtNFCID3[10];
      :btDID, :uint8,#     uint8_t  btDID;
      :btBS, :uint8,#     uint8_t  btBS;
      :btBR, :uint8,#     uint8_t  btBR;
      :btTO, :uint8,#     uint8_t  btTO;
      :btPP, :uint8,#     uint8_t  btPP;
      :abtGB, [:uint8, 48],#     uint8_t  abtGB[48];
      :szGB, :size_t,#     size_t  szGB;
      :ndm, DepEnum
    )
  end


  class TargetInfo < FFI::Union
  	pack 1
    layout(
      :nai, ISO14443a,
      :nfi, Felica,
      :nbi, ISO14443b,
      :nii, ISO14443bi,
      :nsi, ISO14443b2sr,
      :nci, ISO14443b2ct,
      :nji, Jewel,
      :ndi, DepInfo
    )
  end

  ModulationType = enum(MODULATION_TYPE)
  BaudRate = enum(BAUD_RATE)

  class Modulation < FFI::Struct
  	pack 1
    layout(
      :nmt, ModulationType,
      :nbr, BaudRate
    )
  end

  class Target < FFI::Struct
  	pack 1
    layout(
      :nti, TargetInfo,
      :nm, Modulation
    )

    def processed!
    	@processed = true
    end

    def processed?
    	defined?(@processed) && @processed
    end

    def sak
			self[:nti][:nai][:btSak]
    end
  end

  ###
  #Version checking before wrapping the rest of the library to prevent
  #name method matching errors.
  attach_function :nfc_version, [], :string

  attach_function :nfc_perror, [ :pointer, :string], :void
  attach_function :nfc_list_devices, [ :pointer, :pointer, :size_t], :size_t

  attach_function :nfc_initiator_init, [:pointer], :int

  attach_function :nfc_device_set_property_bool, [
  	:pointer, #nfc_device *pnd
  	enum(PROPERTIES), #property constant
  	:bool # value
  ], :int

  attach_function :nfc_open, [ :pointer, :string ], :pointer
  attach_function :nfc_close, [ :pointer ], :void

  attach_function :iso14443a_crc, [
  	:pointer, #uint8_t *pbtData
  	:size_t, #size_t szLen
  	:pointer #uint8_t *pbtCrc
  ], :void

  attach_function :nfc_initiator_poll_dep_target, [
  	:pointer, #nfc_device *pnd
  	enum(DEP_MODE), #nfc_dep_mode
    enum(BAUD_RATE), #nfc_baud_rate
    :pointer, #nfc_dep_info *pndiInitiator
    :pointer, #nfc_target *pnt
    :int #timout
  ], :int

	attach_function :nfc_initiator_poll_target, [
		:pointer, #device
		:pointer, #modulations
		:size_t, #modulations size
		:uint8, #targets count
		:uint8, #period
		:pointer #targets
	], :int

	attach_function :nfc_initiator_list_passive_targets, [
	  :pointer, # device
	  Modulation.by_value, # modulation
	  :pointer, # array of targets
	  :size_t # maximum amount of targets
	], :int

	attach_function :nfc_initiator_select_passive_target, [
		:pointer, #device
		Modulation.by_value, # modulation
		:pointer, # pbInitData (uid)
		:size_t, # uid size
		:pointer, #target
	], :int

	attach_function :nfc_initiator_transceive_bytes, [
		:pointer, #device
		:pointer, #byte array to transmit
		:size_t, #number of bytes to transmit
		:pointer, #response buffer
		:size_t, #response buffer size
		:int, #timeout
	], :int

	attach_function :nfc_initiator_poll_target, [
	  :pointer, # device
	  :pointer, # array of modulations
	  :size_t, #number of modulations
	  :uint8, #number of tags for each modulation,
	  :uint8, #period
	  :pointer #target
	], :int

	attach_function :str_nfc_target, [:pointer, :pointer, :bool], :int

	attach_function :nfc_initiator_select_dep_target, [
		:pointer, 
		enum(DEP_MODE), 
		enum(BAUD_RATE), 
		:pointer, 
		:pointer, 
		:int
	], :int

	attach_function :nfc_initiator_deselect_target, [:pointer], :int
  attach_function :nfc_init, [ :pointer ], :pointer
  attach_function :nfc_exit, [ :pointer ], :void

  def self.crc(data)
		data_ptr = FFI::MemoryPointer.new(:uint8, data.length)
		data_ptr.put_bytes(0, data)

		crc_ptr = FFI::MemoryPointer.new(:uint8, 2)
		crc_ptr.put_bytes(0, "\x0\x0")

		iso14443a_crc(data_ptr, data.length, crc_ptr)
		crc_ptr.get_bytes(0, 2).to_s
  end

  def self.crc_hex(data)
  	crc(data).unpack('H*').pop
  end

  def self.debug_target(target)
  	str_pointer = FFI::MemoryPointer.new(:pointer)
		str_nfc_target(str_pointer, target, true)
		puts str_pointer.get_pointer(0).get_string(0)
  end
end
