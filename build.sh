#!/bin/bash

# Use Flutter SDK version 3.22.2 (which includes Dart 3.8.0)
FLUTTER_VERSION="3.22.2"

# Download Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Git safety config
git config --global --add safe.directory /vercel/path0/flutter

# Use ONLY local flutter for all commands
./flutter/bin/flutter --version
./flutter/bin/flutter config --no-analytics
./flutter/bin/flutter pub get
./flutter/bin/flutter build web --release --web-renderer canvaskit --base-href "/"
