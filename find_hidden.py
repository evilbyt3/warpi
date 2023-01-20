#!/usr/bin/env python
import json
import sys

with open(sys.argv[1]) as f:
    k_dict = json.load(f)

print("MAC-Channel-Freq-Hidden")
for d in k_dict:

    # Only traverse WiFi Access Points
    if d['kismet.device.base.type'] == "Wi-Fi AP":

        # Detect hidden nets
        is_hidden = 0
        if d['kismet.device.base.name'] == "":
            is_hidden = 1


        print("{}-{}-{}-{}".format(
            d['kismet.device.base.macaddr'],
            d['kismet.device.base.channel'],
            d['kismet.device.base.frequency'],
            is_hidden
        ))

# d['kismet.device.base.macaddr'],
# d['kismet.device.base.channel'],
# d['kismet.device.base.frequency'],
# d['kismet.device.base.manuf']
# d['kismet.device.base.type'],
# d['kismet.device.base.packets.crypt'],
# d['dot11.device']['dot11.device.num_associated_clients'],
# d['kismet.device.base.commonname']
