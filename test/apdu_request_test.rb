require 'test_helper'
require 'ruby-nfc/apdu/request'

class PostTest < MiniTest::Unit::TestCase
  def test_raise_apdu_error_if_length_too_small
    e = assert_raises(APDU::Error) {APDU::Request.from_string("123")}
    assert_match e.message, /too short/
  end

  def test_raise_apdu_error_if_wrong_command_data_length
    apdu = "\x01\x02\x03\x04\x05\xDE\xAD\xBE\xEF"
    e = assert_raises(APDU::Error) {APDU::Request.from_string(apdu)}
    assert_match e.message, /Wrong Lc/

    apdu << "\xAA\xBB\xCC"
    e = assert_raises(APDU::Error) {APDU::Request.from_string(apdu)}
    assert_match e.message, /Wrong Lc/
  end

  def test_from_string_method
    apdu = "\x01\x02\x03\x04\x05\xDE\xAD\xBE\xEF\xAA\x06"
    request = APDU::Request.from_string(apdu)
    request_helper(request) 
  end

  def test_from_hex_string_method_wrong_format
    apdu = "0102030405DEADBEEFAA0"
    e = assert_raises(APDU::Error) {APDU::Request.from_hex_string(apdu)}
    assert_match e.message, /Wrong format/

    apdu = "0102030405DEADBEEFAA0Z"
    e = assert_raises(APDU::Error) {APDU::Request.from_hex_string(apdu)}
    assert_match e.message, /Wrong format/
  end

  def test_from_hex_string_method
    apdu = "0102030405DEADBEEFAA06"
    request = APDU::Request.from_hex_string(apdu)
    request_helper(request)
  end

  def request_helper(request)
    assert_equal 1, request.cla
    assert_equal 2, request.ins
    assert_equal 3, request.p1
    assert_equal 4, request.p2
    assert_equal 5, request.lc
    assert_equal 6, request.le
    assert_equal "\xDE\xAD\xBE\xEF\xAA", request.data
  end
end
