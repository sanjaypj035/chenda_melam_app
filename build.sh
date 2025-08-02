#!/bin/bash

# Define the Flutter SDK version to use
FLUTTER_VERSION="3.19.0"

# Download and extract the Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Add Flutter to the PATH for the rest of the script
export PATH="$PATH:$(pwd)/flutter/bin"

# IMPORTANT: Fix the Git dubious ownership error
git config --global --add safe.directory /vercel/path0/flutter

# Get project dependencies
flutter pub get

# Build the web application with a relative base-href
flutter build web --release --web-renderer canvaskit --base-href ./