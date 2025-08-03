#!/bin/bash
set -e

# Flutter version to install
FLUTTER_VERSION="3.22.2"

# Download Flutter SDK archive
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Extract it
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Add flutter to path
export PATH="$(pwd)/flutter/bin:$PATH"

# Fix Git safe directory BEFORE using Flutter
git config --global --add safe.directory "$(pwd)/flutter"

# Disable analytics
flutter config --no-analytics

# Verify Flutter and Dart version
flutter --version

# ✅ Use *this* flutter's pub command (not system Dart)
flutter pub get

# Build the Flutter web app
flutter build web --release --web-renderer canvaskit --base-href "
