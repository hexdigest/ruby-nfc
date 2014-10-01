require_relative './tag'

module Mifare
  # tag
  attach_function :mifare_ultralight_connect, [:pointer], :int
  # tag
  attach_function :mifare_ultralight_disconnect, [:pointer], :int

	# tag, page number, page data
  attach_function :mifare_ultralight_read, [:pointer, :uchar, :pointer], :int

	# tag, blocknumber, block data
  attach_function :mifare_ultralight_write, [:pointer, :uchar, :pointer], :int

  module Ultralight
    class Tag < Mifare::Tag
      def select(&block)
      	@reader.set_flag(:NP_AUTO_ISO14443_4, false)

        res = Mifare.mifare_ultralight_connect(@pointer)
        if 0 == res 
					super
				else
					raise Mifare::Error, "Can't select tag: #{res}"
        end
      end

      def deselect
				Mifare.mifare_ultralight_disconnect(@pointer)
				super
      end

			# block number to read
      def read(page_num = nil)
				data_ptr = FFI::MemoryPointer.new(:uchar, 4)
        res = Mifare.mifare_ultralight_read(@pointer, page_num, data_ptr)

        raise Mifare::Error, ("Can't read page 0x%02x" % page_num) unless 0 == res

        data_ptr.get_bytes(0, 4).force_encoding('ASCII-8BIT')
      end

			# @data - 16 bytes represented by hexadecimal string
			# @block_num - number of block to write to
      def write(data, page_num = nil)
				raise Mifare::Error, "Wrong data given" if data !~ /^[\da-f]{8}$/i

				data_ptr = FFI::MemoryPointer.new(:uchar, 4)
				data_ptr.put_bytes(0, [data].pack('H*'))

				res = Mifare.mifare_classic_write(@pointer, block_num, data_ptr)
				raise Mifare::Error, ("Can't write page 0x%02x" % page_num) unless 0 == res

				res
      end

			# Check's if our tag class is able to handle this LibNFC::Target
			def self.match?(target)
				target.sak == Mifare::SAKS[:ULTRALIGHT]
			end
    end
  end
end
