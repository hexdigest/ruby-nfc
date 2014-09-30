ruby-nfc
========

NFC library for Ruby programming language

Prerequisites
------------

* Install libusb first. For Ubuntu run:
  ```
  apt-get install libusb-dev
  ```
* Download and install [libnfc](https://bintray.com/nfc-tools/sources/libnfc). Ruby-nfc currently works with 1.7.x branch
  
  ```
  # tar xjvf libnfc-1.7.1.tar.bz2
  # cd libnfc-1.7.1/
  # ./configure
  # make && make install
  ```
  
  Or if you're using Ubuntu Utopic Unicorn or higher version еnable "Universe" repository and then run:
  ```
  sudo apt-get install libfreefare-bin
  ```
  You may need to copy some system files from libnfc tarball anyway:

    ```
    sudo cp ./contrib/linux/blacklist-libnfc.conf /etc/modprobe.d/
    sudo cp ./contrib/udev/42-pn53x.rules /etc/udev/rules.d/
    ```
* Download and install [libfreefare](https://code.google.com/p/libfreefare/):
  ```
  # git clone https://code.google.com/p/libfreefare/
  # cd libfreefare
  # autoreconf -vis
  # ./configure && make && make install
  ```
  
* Look at lsusb output and make sure that your reader is present in 42-pn53x.rules
* Install appropriate driver for your NFC reader (if required)
* If your reader is plugged in unplug it and plug it again. If you run example below and get "Device or resource busy" error then you need to reboot your system before you can continue.

Usage
-----

```ruby
p "Library version: %s" % RubyNFC.version
readers = RubyNFC::Reader.all
p "Available readers: %s" % readers.to_s

readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag) do |tag|
  begin
  	p "Tag uid: %s" % tag.uid_hex

		# This is how you can distinguish different type of tags
		# and process them separately
		# Some tags can have several interfaces i.e. PayPass/payWave cards
		# with mifare chip on board so this case statement also defines priority
		# of tag types
		case tag
		when Mifare::Classic::Tag
  		tag.select do
  			if auth(4, :key_a, "FFFFFFFFFFFF")
					p "authenticated!"
					processed!
  			end
  		end
  	when Mifare::Ultralight::Tag
  		tag.select do
  			p "Page 1: %s" % read(1).unpack('H*').pop
  		end
		when IsoDep::Tag
			tag.select do
				# sending APDU command to tag using hex binary format
				p tag << "\x00\xA4\x04\x00\x06\xF7\x52\x46\x54\x41\x01" 
				# sending APDU command to tag using hex string format
				# tag response will be delivered in a same format as an input
				p tag << 'A00D010018B455CAF0F331AF703EFA2E2D744EC7E22AA64076CD19F6D0'
				processed!
			end
		end
  rescue Exception => e
    p e
  end
end
```

Debugging
---------

To see additional debug info from libnfc run your program as follows:
```
LIBNFC_LOG_LEVEL=3 ruby listen.rb
```
