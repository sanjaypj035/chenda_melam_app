#!/bin/bash

# Use Flutter SDK version 3.22.2 (includes Dart 3.8.0)
FLUTTER_VERSION="3.22.2"

# Download and extract the correct Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Fix git safe directory issue
git config --global --add safe.directory /vercel/path0/flutter

# Verify Flutter version
flutter --version

# Install dependencies
flutter pub get

# Build web with proper base-href
flutter build web --release --web-renderer canvaskit --base-href "/"
