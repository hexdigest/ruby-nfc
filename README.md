About ruby-nfc
========

This gem brings some NFC functionality for Ruby programming language.
It allows to:
* Read and modify contents of Mifare tags
* Send APDU commands to Android HCE or Blackberry VTE devices
* Communicate with dual-interface smart cards like Master Card PayPass or Visa payWave cards

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

Installation
------------
```
gem install ruby-nfc
```

Usage
-----

```ruby
require 'ruby-nfc'

puts "Library version: %s" % NFC.version
readers = NFC::Reader.all
puts "Available readers: %s" % readers.to_s

# The order of tag types in poll arguments defines priority of tag types
readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag, NFC::Tag) do |tag|
  begin
  	puts "Applied #{tag.class.name}: #{tag}"

		case tag
		when Mifare::Classic::Tag
  		tag.select do
  			# Perform authentication to block 0x04 with the Key A that equals 
  			# to "\xFF\xFF\xFF\xFF\xFF\xFF" you can also use "FFFFFFFFFFFF"
  			# representation. In this case it will be automatically packed to 6 bytes
  			if auth(4, :key_a, "FFFFFFFFFFFF")
					puts "authenticated!"
					processed! # mark tag as processed so even if it supports different
										 # protocol poll method will continue with another physical
										 # tag
  			end
  		end
  	when Mifare::Ultralight::Tag
  		tag.select do
  			puts "Page 1: %s" % read(1).unpack('H*').pop
  			processed!
  		end
		when IsoDep::Tag
			aid = ["F75246544101"].pack('H*')
			tag.select(aid) do
				# sending APDU command to tag using send_apdu method
				apdu = ['A00D010018B455CAF0F331AF703EFA2E2D744EC7E22AA64076CD19F6D0'].pack('H*')
				puts send_apdu(apdu).unpack('H*').pop

				# sending APDU command with "<<" operator which is alias to send_apdu
				# response = tag << apdu
				# puts response.unpack('H*').pop
				processed!
			end
		end
  rescue Exception => e
    puts e
  end
end

```

This example should provide similar output when you apply your tags to NFC-reader:
```
Library version: 1.7.1
Available readers: [acr122_usb:001:009]
Applied Mifare::Classic::Tag: bde74d1d Mifare Classic 4k SAK: 0x18
authenticated!
Applied Mifare::Classic::Tag: 25161b49 Infineon Mifare Classic 1k SAK: 0x88
authenticated!
Applied Mifare::Ultralight::Tag: 04a42572373080 Mifare UltraLight SAK: 0x0
Page 1: 72373080
Applied IsoDep::Tag: a0d98978
aeee833d6a26476221290c3e4978290cce67422257aa37fedeca655fe7c67a5636669529e676a7c53fa51b9af3ae62e631b6cbebd4a65228a2fbf9cfe8b860e5efc69000
Applied Mifare::Ultralight::Tag: 04ffc68aaa2b80 Mifare UltraLight SAK: 0x0
Page 1: 8aaa2b80
Applied IsoDep::Tag: 087a1ae3
Application not found: f75246544101
```

Debugging
---------

To see additional debug info from libnfc run your program as follows:
```
LIBNFC_LOG_LEVEL=3 ruby listen.rb
```

License
-------

The MIT License (MIT)

Copyright (c) 2014 Maxim M. Chechel <maximchick@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
