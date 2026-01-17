#!/usr/bin/env bash
set -e

# Flutter Web build on Vercel
FLUTTER_VERSION="3.22.3"

echo "Downloading Flutter SDK (v$FLUTTER_VERSION)..."
git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git flutter_sdk
export PATH="$PWD/flutter_sdk/bin:$PATH"

flutter --version
flutter config --enable-web

# Ensure the Web platform exists (some mobile-first projects don't include /web)
if [ ! -d "web" ]; then
  echo "Web platform not found. Creating web support..."
  flutter create . --platforms=web
fi

flutter pub get
flutter build web --release
