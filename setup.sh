#!/usr/bin/env bash
# Run once inside this folder:  bash setup.sh
set -e
mkdir -p /tmp/ghosts_keep && cp -r lib pubspec.yaml /tmp/ghosts_keep/
flutter create --platforms=android --org dev.ghosts --project-name ghosts_spike .
rm -rf lib pubspec.yaml test && cp -r /tmp/ghosts_keep/lib ./lib && cp /tmp/ghosts_keep/pubspec.yaml ./pubspec.yaml
M=android/app/src/main/AndroidManifest.xml
# localhost server needs cleartext http + sockets
grep -q usesCleartextTraffic "$M" || sed -i 's/<application/<application android:usesCleartextTraffic="true"/' "$M"
grep -q 'permission.INTERNET' "$M" || sed -i '0,/<manifest[^>]*>/s//&\n    <uses-permission android:name="android.permission.INTERNET"\/>/' "$M"
flutter pub get
echo "Done. Connect a phone (USB debugging) and run:  flutter run"
