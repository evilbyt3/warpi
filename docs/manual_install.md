
> **Note**: all the required files can be found in the [piset directory](../piset/)

## OS Installation & Setup

For this build I choose the [Raspberry Pi OS Lite 64-bit](https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64-lite.img.xz): : a lightweight OS without GUI and is recommended to be used since it is stable and developed specifically for the Pi. So just flash the image onto the SD card
- Linux: `sudo dd if=/path/to/manjaro.img of=/dev/sdX status="progress"`
- Windows: use [Rufus](https://rufus.ie/en/)
- Cross-Platform: [RPI-Imager](https://www.raspberrypi.com/software/)

Then just follow the instructions from the installation & once logged in setup the following:
- update & upgrade: `sudo apt update && sudo apt upgrade`
- configure WiFi to connect to the phone's hotspot , place a file [wpa_supplicant.conf](https://www.raspberrypi.com/documentation/computers/configuration.html#adding-the-network-details-to-your-raspberry-pi) in `x:\boot` partition:
```bash
country=US # Your 2-digit country code ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev 
network={ 
	ssid="YOUR_NETWORK_NAME" 
	psk="YOUR_PASSWORD" 
	key_mgmt=WPA-PSK 
}
```

## Interfacing w The GPS Module
The GPS module chosen has 4 pins:
- VCC *(Supply Voltage)* & GND *(Ground)* - for power
- Tx *(Transmitter)* & Rx *(Receiver)* - for data comms

The module provides [NMEA](http://aprs.gids.nl/nmea/) data strings to the TX pin, that once parsed will yield GPS information *(i.e longitude, latitude)*. More info can be found [here](https://robu.in/wp-content/uploads/2017/09/NEO-M8-FW3_ProductSummary_UBX-16000345.pdf)

![](https://content.instructables.com/FUO/3N6L/KA6SGHDQ/FUO3N6LKA6SGHDQ.jpg?auto=webp&frame=1&width=1024&fit=bounds&md=9123c8b5ac3825277b2bf7dbfe1a9287)

Once the module is connected & the Pi is powered on, some changes need to be:
- enable [UART](https://electronicshacks.com/raspberry-pi-serial-uart-tutorial/) in [config.txt](https://elinux.org/RPiconfig)
```bash
# contains conf params read on boot-up from SD card
sudo vim /boot/config.txt   

# enable options
dtparam=spi=on
dtoverlay=pi3-disable-bt  
core_freq=250
enable_uart=1
force_turbo=1
```
- replace content in [cmdline.txt](https://elinux.org/RPi_cmdline.txt) with *(recommended to make a copy of the original: `sudo cp /boot/cmdline.txt /boot/cmdline.txt.bak`)*
```bash
dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
```
- reboot: `sudo reboot`

Upon reboot check if your serial port is enabled: `ls /dev/ttyS0` *(more on [/dev/tty](https://www.mit.edu/afs.new/athena/system/rhlinux/redhat-6.2-docs/HOWTOS/other-formats/html/Text-Terminal-HOWTO-html/Text-Terminal-HOWTO-6.html) meaning)*

```bash
[warpi@warpi ~]$ sudo cat /dev/ttyS0
$GPRMC,,V,,,,,,,,,,N*53
$GPVTG,,,,,,,,,N*30
$GPGGA,,,,,,0,00,99.99,,,,,,*48
$GPGSA,A,1,,,,,,,,,,,,,99.99,99.99,99.99*30
$GPGSV,1,1,00*79
$GPGLL,,,,,,V,N*64
$GPRMC,,V,,,,,,,,,,N*53
$GPVTG,,,,,,,,,N*30
$GPGGA,,,,,,0,00,99.99,,,,,,*48
$GPGSA,A,1,,,,,,,,,,,,,99.99,99.99,99.99*30
$GPGSV,1,1,00*79
$GPGLL,,,,,,V,N*64
```

> **Note**: with this GPS module I noticed that it [takes a while to start working once you're outside](https://stackoverflow.com/questions/48663880/gps-nmea-output-getting-valid-gpgsv-but-not-valid-gpgga-gprmc). So don't panic if you're inside & you don't get any latitude or longitude

Now you can read & interpret the NMEA data with programming languages *(python:  [minicon](https://help.ubuntu.com/community/Minicom) [pynmea2](https://openbase.com/python/pynmea2))* OR with something like  [gpsd](https://gpsd.io/) - a gps service daemon

```bash
sudo apt install gpsd

# link serial port with gpsd
sudo nvim /etc/default/gpsd
START_DAEMON="true"
GPSD_OPTIONS="/dev/ttyS0"
DEVICES=""
USBAUTO="true"

# enable service
sudo systemctl enable gpsd && sudo systemctl start gpsd

# Now can see data with
#  - CLI: cgps, gpsmon
#  - GUI: xgps
```

![](https://i.imgur.com/zUsKprY.png)

## Installing Alfa Network AWS1900 Driver

```bash
# Install linux kernel headers & reboot
sudo apt-get install dkms raspberrypi-kernel-headers build-essential libelf-dev
sudo reboot
# Clone repo
git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git

# Build & Install driver
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM64_RPI = n/CONFIG_PLATFORM_ARM64_RPI = y/g' Makefile
sed -i 's/^MAKE="/MAKE="ARCH=arm64\ /' dkms.conf
sudo make ARCH=arm64 dkms_install
sudo make dkms_install
sudo reboot

# Other helpfull cmds
# sudo make dkms_remove
# sudo dkms remove 8812au/5.6.4.2_35491.20191025 --all
# uname -r

# LED should now be blinking 
# Check new interface
warpi@warpi:~ $ ip a
...
4: wlan1: <NO-CARRIER,BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2312 qdisc mq state DORMANT group default qlen 1000
    link/ether 00:c0:ca:b0:7e:00 brd ff:ff:ff:ff:ff:ff

# Enable network manager
sudo systemctl enable NetworkManager && sudo systemctl start NetworkManager
```

> **Note**: had some setbacks with installing the drivers depending on your OS you might encouter them as well: if lost follow the [docs](https://github.com/aircrack-ng/rtl8812au#for-raspberry-rpi) & this [savior forum thread](https://dietpi.com/forum/t/rpi-install-edimax-ew-7811uac-rtl8812au-driver/1116/29)

### Setting up [Kismet](https://www.kismetwireless.net/)


Installing it per the [documentation](https://www.kismetwireless.net/docs/readme/installing/linux/):
```bash

sudo apt install build-essential git libwebsockets-dev pkg-config zlib1g-dev libnl-3-dev libnl-genl-3-dev libcap-dev libpcap-dev libnm-dev libdw-dev libsqlite3-dev libprotobuf-dev libprotobuf-c-dev protobuf-compiler protobuf-c-compiler libsensors4-dev libusb-1.0-0-dev python3 python3-setuptools python3-protobuf python3-requests python3-numpy python3-serial python3-usb python3-dev python3-websockets librtlsdr0 libubertooth-dev libbtbb-dev

# https://www.kismetwireless.net/packages/#debian-bullseye
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/bullseye bullseye main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

Enable GPS in `/etc/kismet/kismet.conf`:
```bash
# gps=serial:device=/dev/ttyACM0,name=laptop
# gps=tcp:host=1.2.3.4,port=4352
 gps=gpsd:host=localhost,port=2947
# gps=virtual:lat=123.45,lon=45.678,alt=1234
# gps=web:name=gpsweb
```
And add the [wigle format](https://wigle.net/phpbb/viewtopic.php?t=2523) along with [pcapng](https://pcapng.com/) in `/etc/kistmet/kismet_logging.conf` for further analysis:
```bash
log_types=kismet,wiglecsv,pcapng
# also increase these if u don't have enough resources (i.e memory)
# By default, data source records are generated once per minute
kis_log_datasources_rate=30
# By default, channel history is logged every 20 seconds
kis_log_channel_history_rate=20
```

Then you can start your wardriving sessions with: `sudo kismet -t <title>` & enter the dashboard from a browser @ `http://<PI_LOCAL_IP>:2501/`

![](https://i.imgur.com/jYy31pA.png)
