#!/bin/bash

read -p "Ange TV:ns IP-adress (t.ex. 192.168.1.10): " TV_IP

if [ -z "$TV_IP" ]; then
    echo "Ingen IP-adress angavs. Avbryter."
    exit 1
fi

echo "Ansluter till TV:n på $TV_IP..."
adb connect "$TV_IP"
sleep 2

APPS=(
    "com.netflix.ninja"
    "com.amazon.amazonvideo.livingroom"
    "com.google.android.youtube.tv"
    "com.google.android.youtube.tvmusic"
    "com.google.android.videos"
    "com.google.android.play.games"
    "fusion.android.tv.demo"
    "com.vestel.overlay.tv.settings.retailvideo"
    "uk.co.freeview.bbc"
    "uk.co.freeview.itv"
    "uk.co.freeview.uktv"
    "uk.co.freeview.explore"
    "uk.co.freeview.amc_catchup"
    "uk.co.freeview.onnow"
    "uk.co.freeview.bbc_sounds"
    "uk.co.freeview.ch5"
    "uk.co.freeview.stv"
    "uk.co.freeview.amc_horror"
    "uk.co.freeview.ch4_vod"
)

echo "Börjar avinstallera appar..."

for APP in "${APPS[@]}"; do
    echo -n "Tar bort $APP... "
    adb -s "$TV_IP:5555" shell pm uninstall --user 0 "$APP" >/dev/null 2>&1
    echo "Klar!"
done

echo "Tömmer gemensam cache..."
adb -s "$TV_IP:5555" shell pm clear-cache >/dev/null 2>&1

echo "---------------------------------"
echo "Rensning slutförd!"

echo "Tömmer settings steg 1"
adb -s $TV_IP:5555 shell pm clear com.android.tv.settings

echo "---------------------------------"
echo "Rensning slutförd steg 1!"

echo "Tömmer settings steg 2"
adb -s $TV_IP:5555 shell pm clear com.vestel.overlay.tv.settings

echo "---------------------------------"
echo "Rensning slutförd steg 2!"

read -p "Vill du starta om TV:n nu? (j/n): " REBOOT_ANSWER

if [[ "$REBOOT_ANSWER" =~ ^[JjYy]$ ]]; then
    echo "Skickar omstartskommando till TV:n..."
    adb -s "$TV_IP:5555" reboot
    echo "TV:n startar nu om. Vänta en minut innan du försöker uppdatera."
else
    echo "Hoppar över omstart. Glöm inte att starta om TV:n innan du uppdaterar systemet."
fi
