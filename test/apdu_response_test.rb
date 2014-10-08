require 'test_helper'
require 'ruby-nfc/apdu/response'

class APDUResponseTest < MiniTest::Unit::TestCase
	def setup
		@response = APDU::Response.new("\x01\x02\x03\x04\x69\x85")
	end

  def test_raise_apdu_error_if_length_too_small
    assert_raises(APDU::Error) { APDU::Response.new("") }
  end

  def test_data
  	assert_equal "\x01\x02\x03\x04", @response.data
  end

  def test_sw
  	assert_equal 0x6985, @response.sw
  end

  def test_sw1
  	assert_equal 0x69, @response.sw1
  end

  def test_sw2
  	assert_equal 0x85, @response.sw2
  end

	def test_raise_errno
		e = assert_raises(APDU::Errno) { @response.raise_errno! }
		assert_equal 0x6985, e.code
	end

end
