#!/bin/bash

# Fråga efter IP-adressen
read -p "Ange TV:ns IP-adress (t.ex. 192.168.1.10): " TV_IP

if [ -z "$TV_IP" ]; then
    echo "Ingen IP-adress angavs. Avbryter."
    exit 1
fi

echo "Ansluter till TV:n på $TV_IP..."
adb connect "$TV_IP"
sleep 2 # Vänta lite så anslutningen hinner etableras helt

# Lista på alla stora appar och brittiskt skräp som ska bort
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
)

echo "Börjar avinstallera appar..."

# Loopa igenom listan och ta bort varje app
for APP in "${APPS[@]}"; do
    echo -n "Tar bort $APP... "
    # Styr utskriften till /dev/null för att få en renare terminal
    adb -s "$TV_IP:5555" shell pm uninstall --user 0 "$APP" >/dev/null 2>&1
    echo "Klar!"
done

echo "Tömmer gemensam cache..."
adb -s "$TV_IP:5555" shell pm clear-cache >/dev/null 2>&1

echo "---------------------------------"
echo "Rensning slutförd!"

# Fråga om omstart
read -p "Vill du starta om TV:n nu? (j/n): " REBOOT_ANSWER

if [[ "$REBOOT_ANSWER" =~ ^[JjYy]$ ]]; then
    echo "Skickar omstartskommando till TV:n..."
    adb -s "$TV_IP:5555" reboot
    echo "TV:n startar nu om. Vänta en minut innan du försöker uppdatera."
else
    echo "Hoppar över omstart. Glöm inte att starta om TV:n innan du uppdaterar systemet."
fi
