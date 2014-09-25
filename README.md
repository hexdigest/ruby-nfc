ruby-nfc
========

NFC library for Ruby programming language

Prerequisites
------------

* Install libusb first. 
* Download and install [libnfc](https://code.google.com/p/libnfc/downloads/list). Or if you're using Ubuntu:
  Enable "Universe" repository and then:
  ```
  apt-get install libfreefare-bin
  ```
  You may need to copy some system files from libnfc tarball:

    ```
    sudo cp ./contrib/linux/blacklist-libnfc.conf /etc/modprobe.d/
    sudo cp ./contrib/udev/42-pn53x.rules /etc/udev/rules.d/
    ```
* Look at lsusb output and make sure that your reader is present in 42-pn53x.rules
* Download and install [libfreefare](https://code.google.com/p/libfreefare/downloads/list)
* Install appropriate driver for your NFC reader
* Reboot your system
