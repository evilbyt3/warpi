## Clone SD Card

First, insert the SD card containing the custom OS which was used to run on your pi. Verify that it's recognized by listing the disks as follows:
```bash
# fdisk also works
vlaghe@cbox  ~gP/warpi   main ±  lsblk
NAME          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda             8:0    1  59.5G  0 disk
├─sda1          8:1    1   256M  0 part
└─sda2          8:2    1  59.2G  0 part
nvme0n1       259:0    0 953.9G  0 disk
├─nvme0n1p1   259:1    0   511M  0 part  /boot
└─nvme0n1p2   259:2    0 953.4G  0 part
  └─cryptroot 254:0    0 953.4G  0 crypt
    └─vg-root 254:1    0 953.4G  0 lvm   /
```

Depending on your system the path of your sd card may change. In my case the path is: `/dev/sda`. Once you know where it's located, we need to completely clone the SD card:
```bash
# if = input file
# of = output file
sudo dd if=/dev/sda of=/path/to/clone.img bs=1M status="progress"
```

This process will take some time as it will copy what’s in your memory card block by block. The bigger the memory card size is, longer it would take. You will see in the command line when the process is finished.

## Shrinking the image

Once the image is cloned, you might notice that the file size is quite big. In my case the image was 59GB *(since I had an SD card of 59GB)*. This can be a problem when it comes to sharing the image with others on the Internet *(not many cloud storage services allow such sizes)*. To shrink it we can use [pyShrink](https://github.com/Drewsif/PiShrink) - a bash script that automatically shrink a pi image that will then resize to the max size of the SD card on boot.

```bash
wget  https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
chmod +x pishrink.sh
sudo pishrink.sh /path/to/your/clone.img /path/to/clone-shrink.img
```

![](https://i.imgur.com/RqKCx20.png)

This will also take some time so go grab a coffee or walk a bit ☕

## Compress the image further

Even after using the shrinking script the image size can still be a bit too much. So to further compress it we can use `tar`, `zip` or `gzip`:

```bash
gzip -9 /path/to/clone-shrink.img
tar -czvf image.tar.gz clone-shrink.img
zip image.zip clone-shrink.img
```

That reduced my image from 3GB to 1GB which is more managable. Now, the only thing left to do is to flash your new image onto a new SD card & test it out.

