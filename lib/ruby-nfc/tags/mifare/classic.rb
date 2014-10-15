require_relative './tag'

module Mifare
	# Adding some Classic related stuff to Mifare module
	
  # tag
  attach_function :mifare_classic_connect, [:pointer], :int
  # tag
  attach_function :mifare_classic_disconnect, [:pointer], :int
  # tag, blocknumber, key
  attach_function :mifare_classic_authenticate, [:pointer, :uchar, :pointer, enum(:key_a, :key_b)], :int

	# tag, blocknumber, block data
  attach_function :mifare_classic_read, [:pointer, :uchar, :pointer], :int

	# tag, blocknumber, block data
  attach_function :mifare_classic_write, [:pointer, :uchar, :pointer], :int

	#mifare_classic_init_value (MifareTag tag, const MifareClassicBlockNumber block, const int32_t value, const MifareClassicBlockNumber adr)
	# tag, blocknumber, value, addr 
	attach_function :mifare_classic_init_value, [:pointer, :uchar, :int32, :uchar], :int

	#mifare_classic_increment (MifareTag tag, const MifareClassicBlockNumber block, const uint32_t amount)
	attach_function :mifare_classic_increment, [:pointer, :uchar, :int32], :int

	#mifare_classic_decrement (MifareTag tag, const MifareClassicBlockNumber block, const uint32_t amount)
	attach_function :mifare_classic_decrement, [:pointer, :uchar, :int32], :int

  #mifare_classic_read_value (MifareTag tag, const MifareClassicBlockNumber block, int32_t *value, MifareClassicBlockNumber *adr)
	attach_function :mifare_classic_read_value, [:pointer, :uchar, :pointer, :pointer], :int

	#mifare_classic_transfer (MifareTag tag, const MifareClassicBlockNumber block)
	attach_function :mifare_classic_transfer, [:pointer, :uchar], :int

  module Classic
    class Tag < Mifare::Tag
      def initialize(target, reader)
      	super(target, reader)

      	@auth_block = nil #last authenticated block
      end

      def connect(&block)
      	@reader.set_flag(:NP_AUTO_ISO14443_4, false)

        res = Mifare.mifare_classic_connect(@pointer)
        if 0 == res 
					super
				else
					raise Mifare::Error, "Can't connect to tag: #{res}"
        end
      end

      def disconnect
				Mifare.mifare_classic_disconnect(@pointer)
				super
      end

      # keytype can be :key_a or :key_b
      # key - hexadecimal string key representation like "FFFFFFFFFFFF"
      def auth(block_num, key_type, key)
        raise Mifare::Error, "Wrong key type" unless [:key_a, :key_b].include? key_type
        raise Mifare::Error, "Wrong key length" unless [6, 12].include? key.size

        key_ptr = FFI::MemoryPointer.new(:uchar, 6)
       	key_ptr.put_bytes(0, 6 == key.size ? key : [key].pack("H*"))

        res = Mifare.mifare_classic_authenticate(@pointer, block_num, key_ptr,
        																				 key_type)
				raise Mifare::Error, "Can't autenticate to block 0x%02x" % block_num if 0 != res

				@auth_block = block_num
      end

			# block number to read
      def read(block_num = nil)
      	block_num ||= @auth_block
      	raise Mifare::Error, "Not authenticated" unless block_num

				data_ptr = FFI::MemoryPointer.new(:uchar, 16)
        res = Mifare.mifare_classic_read(@pointer, block_num, data_ptr)

        raise Mifare::Error, "Can't read block 0x%02x" % block_num if 0 != res

        data_ptr.get_bytes(0, 16).force_encoding("ASCII-8BIT")
      end

			# @data - 16 bytes represented by hexadecimal string
			# @block_num - number of block to write to
      def write(data, block_num = nil)
      	block_num ||= @auth_block
      	raise Mifare::Error, "Not authenticated" unless block_num

				write_data = if data =~ /^[\da-f]{32}$/i
      								 [data].pack("H*")
										 elsif 16 == data.size 
												data.dup
										 else
											raise Mifare::Error, "Wrong data given"
										 end

				data_ptr = FFI::MemoryPointer.new(:uchar, 16)
				data_ptr.put_bytes(0, write_data)

				res = Mifare.mifare_classic_write(@pointer, block_num, data_ptr)
        raise Mifare::Error, "Can't write block 0x%02x" % block_num if 0 != res
      end

			# Create value block structure and write it to block
      def init_value(value, addr = nil, block_num = nil)
      	block_num ||= @auth_block
      	raise Mifare::Error, "Not authenticated" unless block_num

      	addr ||= 0

				res = Mifare.mifare_classic_init_value(@pointer, block_num, value, addr)
        raise Mifare::Error, "Can't init value block 0x%02x" % block_num if 0 != res
      end

			# returns only value part of value block
      def value(block_num = nil)
      	v, _ = value_with_addr(block_num)
      	v
      end

			# returns value and addr
      def value_with_addr(block_num = nil)
				block_num ||= @auth_block
      	raise Mifare::Error, "Not authenticated" unless block_num

				value_ptr = FFI::MemoryPointer.new(:int32, 1)
				addr_ptr = FFI::MemoryPointer.new(:uchar, 1)
				res = Mifare.mifare_classic_read_value(@pointer, block_num, value_ptr, addr_ptr)
        raise Mifare::Error, "Can't read value block 0x%02x" % block_num if 0 != res

				[value_ptr.get_int32(0), addr_ptr.get_uchar(0)]
      end

			# Mifare classic increment
      def inc(amount = 1, block_num = nil)
				block_num ||= @auth_block
      	raise Mifare::Error, "Not authenticated" unless block_num
				
				res = Mifare.mifare_classic_increment(@pointer, block_num, amount)
        raise Mifare::Error, "Can't increment block 0x%02x" % block_num if 0 != res
      end

			# Mifare classic decrement
      def dec(amount = 1, block_num = nil)
				block_num ||= @auth_block
      	raise Mifare::Error, "Not authenticated" unless block_num
				
				res = Mifare.mifare_classic_decrement(@pointer, block_num, amount)
        raise Mifare::Error, "Can't decrement block 0x%02x" % block_num if 0 != res
      end

      def transfer(block_num = nil)
				block_num ||= @auth_block
      	raise Mifare::Error, "Not authenticated" unless block_num

				res = Mifare.mifare_classic_transfer(@pointer, block_num)
        raise Mifare::Error, "Can't transfer to block 0x%02x" % block_num if 0 != res
      end

			# Check's if our tag class is able to handle this LibNFC::Target
			def self.match?(target)
				keys = [:CLASSIC_1K, :CLASSIC_1K_EMULATED, :CLASSIC_1K_ANDROID,
					:INFINEON_CLASSIC_1k, :CLASSIC_4K, :CLASSIC_4K_EMULATED]

				Mifare::SAKS.values_at(*keys).include? target.sak
			end
    end
  end
end
