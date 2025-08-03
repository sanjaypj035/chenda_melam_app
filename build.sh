#!/bin/bash

set -e  # Exit on any error

# Download Flutter 3.22.2 (Dart 3.8)
FLUTTER_VERSION="3.22.2"
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Use local Flutter binary ONLY
FLUTTER="./flutter/bin/flutter"

# Allow build inside Vercel
git config --global --add safe.directory /vercel/path0/flutter

# Run using local Flutter
$FLUTTER --version
$FLUTTER config --no-analytics
$FLUTTER pub get
$FLUTTER build web --release --web-renderer canvaskit --base-href "/"
