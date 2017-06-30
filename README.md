About ruby-nfc
========

This gem brings some NFC functionality for Ruby programming language.
It allows you to:
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
  
  You *may* need to copy some system files from libnfc tarball:

    ```
    sudo cp ./contrib/linux/blacklist-libnfc.conf /etc/modprobe.d/
    sudo cp ./contrib/udev/42-pn53x.rules /etc/udev/rules.d/
    ```
* Download and install [libfreefare](https://github.com/nfc-tools/libfreefare):
  ```
  # git clone https://github.com/nfc-tools/libfreefare.git
  # cd libfreefare
  # autoreconf -vis
  # ./configure && make && make install
  ```
  
* Look at the lsusb output and make sure that your reader is present in 42-pn53x.rules file
* Install the appropriate driver for your NFC reader (if required)
* If your reader is plugged in unplug it and plug it in again. If you run the example below and get "Device or resource busy" error then you need to reboot your system before you can continue.
* If you getting "Unable to claim USB interface (Operation not permitted)" error then changing MODE from 0664 to 0666 in 42-pn53x.rules file may help

Installation
------------
```
gem install ruby-nfc
```

Usage
-----

```ruby
require 'ruby-nfc'
require 'logger'

$logger = Logger.new(STDOUT)

def p(str)
	$logger.debug str
end

p "Library version: #{NFC.version}"
readers = NFC::Reader.all
p "Available readers: #{readers}"

# The order of tag types in poll arguments defines priority of tag types
readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag) do |tag|
	begin
		p "Applied #{tag.class.name}: #{tag}"

		case tag
		when Mifare::Classic::Tag
			if tag.auth(4, :key_a, "FFFFFFFFFFFF")
				# Mifare::Classic::Tag.read method reads contents of last authenticated
				# block
				p "Contents of block 0x04: #{tag.read.unpack('H*').pop}"
				# Making random 16-byte string
				rnd = Array.new(16).map{rand(255)}.pack('C*')
				tag.write(rnd)
				p "New value: #{rnd.unpack('H*').pop}"
				tag.processed!
			else
				p "Authentication failed!"
			end
		when Mifare::Ultralight::Tag
			p "Page 1: #{tag.read(1).unpack('H*').pop}"
			tag.processed!
		when IsoDep::Tag
			tag.select! ["F75246544101"].pack('H*')
			# sending APDU command to tag using send_apdu method
			apdu = ['A00D010018B455CAF0F331AF703EFA2E2D744EC7E22AA64076CD19F6D0'].pack('H*')
			p tag.send_apdu(apdu)

			# sending APDU command with "<<" operator which is alias to send_apdu
			response = tag << apdu
			p "status word: #{response.sw.to_s(16)} data: #{response.data.unpack('H*').pop}"
			tag.processed!
		end

	rescue Exception => e
		p e
	end
end
```

This example should provide similar output when you apply your tags to the NFC-reader:
```
D, [2014-10-15T23:21:48.965893 #9846] DEBUG -- : Library version: 1.7.1
D, [2014-10-15T23:21:49.221798 #9846] DEBUG -- : Available readers: [acr122_usb:001:009]
D, [2014-10-15T23:21:53.393871 #9846] DEBUG -- : Applied IsoDep::Tag: a0d98978
D, [2014-10-15T23:21:53.507046 #9846] DEBUG -- : AEEE833D6A26476221290C3E4978290CCE67422257AA37FEDECA655FE7C67A5636669529E676A7C53FA51B9AF3AE62E631B6CBEBD4A65228A2FBF9CFE8B860E5EFC69000
D, [2014-10-15T23:21:53.597682 #9846] DEBUG -- : status word: 9000 data: aeee833d6a26476221290c3e4978290cce67422257aa37fedeca655fe7c67a5636669529e676a7c53fa51b9af3ae62e631b6cbebd4a65228a2fbf9cfe8b860e5efc6
D, [2014-10-15T23:22:03.037690 #9846] DEBUG -- : Applied Mifare::Classic::Tag: 25161b49 Infineon Mifare Classic 1k SAK: 0x88
D, [2014-10-15T23:22:03.058840 #9846] DEBUG -- : Contents of block 0x04: 8ad53ef7f0f4055bf218b418a3fc884b
D, [2014-10-15T23:22:03.075083 #9846] DEBUG -- : New value: 57597505950dc90e569b8bee19852e6e
D, [2014-10-15T23:22:06.436528 #9846] DEBUG -- : Applied Mifare::Classic::Tag: 25161b49 Infineon Mifare Classic 1k SAK: 0x88
D, [2014-10-15T23:22:06.457830 #9846] DEBUG -- : Contents of block 0x04: 57597505950dc90e569b8bee19852e6e
D, [2014-10-15T23:22:06.473809 #9846] DEBUG -- : New value: 05f42ee777e08631cffbb5c8edadbb6d
D, [2014-10-15T23:22:10.001636 #9846] DEBUG -- : Applied Mifare::Classic::Tag: 25161b49 Infineon Mifare Classic 1k SAK: 0x88
D, [2014-10-15T23:22:10.022172 #9846] DEBUG -- : Contents of block 0x04: 05f42ee777e08631cffbb5c8edadbb6d
D, [2014-10-15T23:22:10.039478 #9846] DEBUG -- : New value: f31a513ff3c6cad190fdd570e67259b1
D, [2014-10-15T23:22:13.365357 #9846] DEBUG -- : Applied Mifare::Ultralight::Tag: 04a42572373080 Mifare UltraLight SAK: 0x0
D, [2014-10-15T23:22:13.376352 #9846] DEBUG -- : Page 1: 72373080
D, [2014-10-15T23:22:22.158846 #9846] DEBUG -- : Applied Mifare::Classic::Tag: bde74d1d Mifare Classic 4k SAK: 0x18
D, [2014-10-15T23:22:22.180474 #9846] DEBUG -- : Contents of block 0x04: 00000000000000000000000000000000
D, [2014-10-15T23:22:22.195963 #9846] DEBUG -- : New value: 8a5b666d6b53bb7c3c52e3d2a076da8b
D, [2014-10-15T23:22:27.187482 #9846] DEBUG -- : Applied Mifare::Classic::Tag: bde74d1d Mifare Classic 4k SAK: 0x18
D, [2014-10-15T23:22:27.208464 #9846] DEBUG -- : Contents of block 0x04: 8a5b666d6b53bb7c3c52e3d2a076da8b
D, [2014-10-15T23:22:27.223680 #9846] DEBUG -- : New value: 35adbc1378afd3d48af367809fd4491d
D, [2014-10-15T23:22:31.756429 #9846] DEBUG -- : Applied Mifare::Classic::Tag: bde74d1d Mifare Classic 4k SAK: 0x18
D, [2014-10-15T23:22:31.777233 #9846] DEBUG -- : Contents of block 0x04: 35adbc1378afd3d48af367809fd4491d
D, [2014-10-15T23:22:31.792688 #9846] DEBUG -- : New value: 46b613dae824cd84363340a45805f9a4
```

Debugging
---------

To see additional debug info from libnfc run your program as follows:
```
LIBNFC_LOG_LEVEL=3 ruby examples/listen.rb
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
