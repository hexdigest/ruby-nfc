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
* Download and install [libfreefare](https://code.google.com/p/libfreefare/downloads/list)
  ```
  # tar xjvf libfreefare-0.4.0.tar.bz2
  # cd cd libfreefare-0.4.0/
  # ./configure && make && make install
  ```
  
* Look at lsusb output and make sure that your reader is present in 42-pn53x.rules
* Install appropriate driver for your NFC reader (if required)
* If your reader is plugged in unplug it and plug it again. If you run example below and get "Device or resource busy" error then you need to reboot your system before you can continue.
