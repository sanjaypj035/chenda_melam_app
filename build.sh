#!/bin/bash

# Use Flutter SDK version 3.22.2 (Dart 3.8.0)
FLUTTER_VERSION="3.22.2"

# Download and extract Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Git safe config
git config --global --add safe.directory /vercel/path0/flutter

# Use ONLY local Flutter binary
./flutter/bin/flutter --version
./flutter/bin/flutter pub get
./flutter/bin/flutter build web --release --web-renderer canvaskit --base-href "/"
