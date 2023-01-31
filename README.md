# WarPi

Transform your RaspberryPi into a wardriving rig

Researching how wardriving can be done, how easy it is & what could be the impact


## Hardware
- [Raspberry Pi 3 Model B+](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) : This is the brain - where we will connect everything & run the software. I choose a model 3 since I just had one laying around, but you shouldn't have problems with other models *(it's actually recommended to use a Pi 4 since it has more RAM)*
- [NEO-M8N GPS Module GPS Module](https://www.makerlab-electronics.com/product/ublox-neo-m8n-gps-module/): provides the GPS coordinates to correlate our discovered devices with. This is the cheaper version, hence you'll need some jumper cables or soldering skills to connect it to the Pi. If you don't want to go through all that hassle, the [GlobalSat BU-353-S4 USB GPS Receiver](https://www.amazon.com/GlobalSat-BU-353-S4-Receiver-Black-Improved-New/dp/B098L799NH) would be your pick
- [ELECROW LCD Screen 5 inch](https://www.amazon.com/Elecrow-800x480-Interface-Supports-Raspberry/dp/B013JECYF2): Initially wanted to attach this display to the pi, but since I needed the pins for the GPS module I aborted that thought. However, still might come in handy if the GPS module is connected through USB
- [Micro SD-card 64GB](): chosen so there will be no need to worry about storage
- [Alfa AWUS1900 Network Adapter](https://www.alfa.com.tw/products/awus1900?variant=36473966231624): does all the hard work of recording new devices. The industry standard because it has long-range coverage & Dual-band *(receives both 2.4GHz and  5GHz devices)*. If you don't have one there are [alternatives out there](https://www.youtube.com/watch?v=5MOsY3VNLK8)
- [Powerbank](): will power your Pi, I had one laying around of 7500 mAh => pi alive-time of around 4h. The best solution would be a powerbank of 30000 mAh => 48h alive-time *(if confused see [this article](https://www.powerbankexpert.com/best-raspberry-pi-power-bank/))*
- [SmartPhone](): since I couldn't connect the LCD screen to interact with the pi, I used my phone as the command & control through SSH & for providing hotspot

## Putting Everything Together

### OS Installation & Setup

For this build I choose the [Manjaro ARM Minimal](https://github.com/manjaro-arm/generic-images/releases/download/22.12/Manjaro-ARM-minimal-generic-22.12.img.xz) since I'm quite comfortable with Arch Linux & it's lightweight so it doesn't exhaust much resources. So just flash the image onto the SD card
- Linux: `sudo dd if=/path/to/manjaro.img of=/dev/sdX status="progress"`
- Windows: use [Rufus](https://rufus.ie/en/)
- Cross-Platform: [RPI-Imager](https://www.raspberrypi.com/software/)

Then just follow the instructions from the installation & once logged in setup the following:
- update & upgrade: `sudo pacman -Syu`
- install [yay](https://github.com/Jguer/yay) AUR helper
```bash
# Build manually from source
cd /opt && sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:<USER_GROUP> ./yay  # unsure of GROUP, exec `id`
cd yay && makepkg -si 

# OR easier
sudo pacman -S yay
```
- install required tools: `yay -S `
- configure WiFi to connect to the phone's hotspot , place a file [wpa_supplicant.conf](https://www.raspberrypi.com/documentation/computers/configuration.html#adding-the-network-details-to-your-raspberry-pi) in `x:\boot` partition:
```bash
country=US # Your 2-digit country code ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev 
network={ 
	ssid="YOUR_NETWORK_NAME" 
	psk="YOUR_PASSWORD" 
	key_mgmt=WPA-PSK 
}
```

### Interfacing w The GPS Module
The GPS module chosen has 4 pins:
- VCC *(Supply Voltage)* & GND *(Ground)* - for power
- Tx *(Transmitter)* & Rx *(Receiver)* - for data comms

The module provides [NMEA](http://aprs.gids.nl/nmea/) data strings to the TX pin resulting in GPS information *(i.e longitude, latitude)*. More info can be found [here](https://robu.in/wp-content/uploads/2017/09/NEO-M8-FW3_ProductSummary_UBX-16000345.pdf)

![](https://content.instructables.com/FUO/3N6L/KA6SGHDQ/FUO3N6LKA6SGHDQ.jpg?auto=webp&frame=1&width=1024&fit=bounds&md=9123c8b5ac3825277b2bf7dbfe1a9287)

Once the module is connected & the Pi is powered on some changes need to be:
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

> **Note**: with this GPS module I noticed that it [takes a while to start working once you're outside](https://stackoverflow.com/questions/48663880/gps-nmea-output-getting-valid-gpgsv-but-not-valid-gpgga-gprmc). So don't panic if you're inside & you don't get ant latitude or longitude

Now you can read & interpret the NMEA data with porogramming languages *(python:  [minicon](https://help.ubuntu.com/community/Minicom) [pynmea2](https://openbase.com/python/pynmea2))* OR with something like  [gpsd](https://gpsd.io/) - a gps service daemon

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

## Analysis
- see `stats.ipynb` *(or use [nbviewer](https://nbviewer.org/github/vlagh3/warpi/blob/main/stats.ipynb) to properly render maps)*

