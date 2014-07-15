ruby-nfc
========

NFC library for Ruby programming language

Prerequisites
------------

* Install libusb first
* If you have issues like "Unable to claim USB interface (Operation not permitted)" try to copy ./contrib/linux/blacklist-libnfc.conf file from libnfc tarball to /etc/modprobe.d/ and restart your linux box
* Download and install libnfc: https://code.google.com/p/libnfc/downloads/list
* Download and install libfreefare: https://code.google.com/p/libfreefare/downloads/list
* Install appropriate driver for your NFC reader
