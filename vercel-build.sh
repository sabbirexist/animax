#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.25.0"

echo "Downloading Flutter SDK $FLUTTER_VERSION..."
git clone --depth 1 -b $FLUTTER_VERSION https://github.com/flutter/flutter.git flutter_sdk

export PATH="$PWD/flutter_sdk/bin:$PATH"

flutter --version
flutter config --enable-web
flutter config --no-analytics
flutter config --no-cli-animations

flutter pub get
flutter build web --release
