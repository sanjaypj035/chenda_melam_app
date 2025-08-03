#!/bin/bash

FLUTTER_VERSION="3.22.2"

# Download and extract Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Add Flutter to PATH (optional for debugging)
export PATH="$PATH:$(pwd)/flutter/bin"

# Git safe config (to avoid warnings)
git config --global --add safe.directory /vercel/path0/flutter

# Use downloaded Flutter explicitly
./flutter/bin/flutter --version
./flutter/bin/flutter pub get
./flutter/bin/flutter build web --release --web-renderer canvaskit --base-href "/"
