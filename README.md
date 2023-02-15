# WarPi
Transform your Raspberry-Pi into a wardriving rig. This project came off during my research on how wardriving can be done, how cheap is it & what could be the impact / applications.

| :exclamation:  This project is for testing, educational & research purposes only |
|----------------------------------------------------------------------------------|



## Hardware
- [Raspberry Pi 3 Model B+](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) : This is the brain - where we will connect everything & run the software. I choose a model 3 since I just had one laying around, but you shouldn't have problems with other models *(it's actually recommended to use a Pi 4 since it has more RAM)*
- [NEO-M8N GPS Module GPS Module](https://www.makerlab-electronics.com/product/ublox-neo-m8n-gps-module/): provides the GPS coordinates to correlate our discovered devices with. This is the cheaper version, hence you'll need some jumper cables or soldering skills to connect it to the Pi. If you don't want to go through all that hassle, the [GlobalSat BU-353-S4 USB GPS Receiver](https://www.amazon.com/GlobalSat-BU-353-S4-Receiver-Black-Improved-New/dp/B098L799NH) would be your pick
- [ELECROW LCD Screen 5 inch](https://www.amazon.com/Elecrow-800x480-Interface-Supports-Raspberry/dp/B013JECYF2): Initially wanted to attach this display to the pi, but since I needed the pins for the GPS module I aborted that thought. However, still might come in handy if the GPS module is connected through USB
- [Micro SD-card 64GB](): chosen so there will be no need to worry about storage
- [Alfa AWUS1900 Network Adapter](https://www.alfa.com.tw/products/awus1900?variant=36473966231624): does all the hard work of recording new devices. The industry standard because it has long-range coverage & dual-band *(receives both 2.4GHz and  5GHz devices)*. If you don't have one there are [alternatives out there](https://www.youtube.com/watch?v=5MOsY3VNLK8)
- [Power bank](): will power your Pi, I had one laying around of 7500 mAh => pi alive-time of around 4h. The best solution would be a power bank of 30000 mAh => 48h alive-time *(if confused see [this article](https://www.powerbankexpert.com/best-raspberry-pi-power-bank/))*
- [SmartPhone](): since I couldn't connect the LCD screen to interact with the pi, I used my phone as the command & control through SSH & for providing hotspot


## Putting Everything Together
Once you have all the hardware ready to go you can either:
- go through the installation process [manually](./docs/manual_install.md) *(recommended option to actually learn what you're building & how everything works together)*
- don't want to go through all of that hassle? I have just the right thing for you: a [custom image](https://github.com/vlagh3/warpi/releases) with everything ready to go. Just download & flash it on an SD card: `sudo dd bs=1M if=/path/to/warpi.img of=/dev/sdX status="progres"`


### Warpi Image
Some changes need to be made first:
- add the SSID and password for your hotspot in `/boot/wpa_supplicant-wlan0.conf` *(`wlan0` is the wifi interface, yours might be different - exec `ip a` to find it)*
- add your SSH public key in `.ssh/authorized_keys`
- change the default password from `warpi` with `pass`

Now you can start your phone hotspot, power the warpi on & connect through SSH from your phone via something like [Termux](https://termux.dev/en/).Then, just execute the [run.sh](https://github.com/vlagh3/warpi/blob/main/src/run.sh) bash script to check if everything is setup correctly & start your wardriving session.

> **NOTE**: want to create your own custom image OR improve the existing one? See [here how you could do that](./docs/custom_image.md) & make a [pull request](https://github.com/vlagh3/warpi/pulls)


## Analysis
The `stats.ipynb` notebook provides you with some sample code to easily analyze & visualize the collected data. It includes things such as:
- finding manufacturers from MAC addresses
- seeing what are the most used SSIDs, channels
- open vs hidden networks
- detecting wifi security protocols
- mapping devices, heat-maps, path traversed
- detect ISPs, device type *(e.g phone, car, IoT, printers, wearable's)*
- helper function to merge multiple data sources from different wardriving sessions

> **Hint**: use [nbviewer](https://nbviewer.org/github/vlagh3/warpi/blob/main/stats.ipynb) to properly render maps

## Improvements
My wishlist:
- web dashboard for vizualization: just upload your collected wiglecsvs & get statistics
- transform `run.sh` into a framework for a better UI
- build kit

## Disclaimer
This is a tool, as all technology.
It's neither good nor bad.
Use it to do good, to study and to test.
Never use it do to harm or create damage!

The continuation of this project counts on you!
