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

There's 2 options when it comes to setting up your Pi:
1. manually: detailed [here](./docs/manual_install.md) *(OS install & setup, gps module, alpha drivers & kismet setup)*
2. download the custom build image under releases and flash the image on an SD card: 
  - Windows: with [Etcher](https://www.balena.io/etcher)
  - Linux: `sudo dd bs=1M if=/path/to/warpi.img of/dev/sdX status="progres"`

## Analysis
- see `stats.ipynb` *(or use [nbviewer](https://nbviewer.org/github/vlagh3/warpi/blob/main/stats.ipynb) to properly render maps)*

