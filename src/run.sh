#!/bin/bash

function panic() {
  echo -e "[!] $1" && exit 1
}

# Check services
systemctl is-active --quiet sshd && echo "[+] sshd service running" || panic "sshd is NOT running"
systemctl is-active --quiet sshd && echo "[+] gpsd service running" || panic "gpsd is NOT running"

# Check if gps module is loaded & working


# Only 1 wifi interface? (we need 2)
[[ "$(ls -la /sys/class/net/ | grep wlan | wc -l)" -le 1 ]] && panic "detected only 1 wifi interface, you need 2"

# Check if wifi interface can enter monitor mode
[[ -z "$(iw list | grep -A 10 "Supported interface modes" | grep monitor)" ]] && panic "none of your wifi interfaces support monitor mode :("


# Check if connected to wifi hotspot
is_conn="$(nmcli conn show --active | grep wifi)"
wifiIntf="$(echo $is_conn | awk '{print $4}')"
localIP="$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | grep -i "$wifiIntf" | awk '{print $2}' | cut -f1 -d'/')"

[ -z "$is_conn" ] && panic "Not connected to wifi: \n - is your mobile hotspot runnning? \n - check your wpa_supplicant.conf \n - is your interface up? exec ip a"
echo "[+] Connected to $(echo $is_conn | awk '{print $1}') on $wifiIntf with IP: $localIP"


# Wait until gps data syncs: available lat & lon
echo "[*] Waiting for gps lat & lon..."
counter=0
while true; do
  has_location="$(gpspipe -w -n 10 | grep -m 1 lon)"
  [[ -n "$has_location" ]] && echo "Got lat & lon. Starting wardriving :D" && break
  sleep 10
  counter=$((counter+10))

  # if 20 mins passed & no location data, notify user
  [[ $counter -gt 1200 ]] && echo -e "[?] 20 min have passed & not location data detected...\n\t maybe check cgps/gpsmon manually?"
done

# Start the wardriving session
#
# =-=-=-= TMUX =-=-=-=-
#     1          2
# |--------| |--------|
# | gpsmon | |  htop  |
# |--------| |--------|
# | kismet |
# |--------|

# create new tmux session
tmux new-session -d -s wardriving

# create first window
tmux rename-window "HTOP"
tmux send-keys "htop" C-m

# create second window
tmux new-window -t wardriving:1 -n "GPS/Kismet"
tmux split-window -v
tmux send-keys "gpsmon" C-m
tmux send-keys "cd ~/data && kismet -t $1" C-m

# attach to session
tmux attach-session -t wardriving
