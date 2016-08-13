#! /bin/bash

set -x

id -a
pwd

echo "no" | android create avd -n zanavi21 -f -t android-21 --abi default/armeabi-v7a --skin "WXGA720"
cat ~/.android/avd/zanavi21.avd/config.ini

mksdcard -l e 18000M sdcard.img
echo 'mtools_skip_check=1' > ~/.mtoolsrc
android list targets

import -window root $CIRCLE_ARTIFACTS/capture000a.png

echo "--- emulator start ---"
emulator -avd zanavi21 -sdcard sdcard.img -no-audio &

echo "waiting for emulator..."
circle-android wait-for-boot

echo "--- emulator up and running ---"

sleep 210

adb shell input keyevent 82

sleep 10

import -window root $CIRCLE_ARTIFACTS/capture_emulator_running.png
