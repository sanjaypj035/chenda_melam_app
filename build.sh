#!/bin/bash

FLUTTER_VERSION="3.22.2"

curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

export PATH="$PATH:$(pwd)/flutter/bin"

git config --global --add safe.directory /vercel/path0/flutter

./flutter/bin/flutter pub get

./flutter/bin/flutter build web --release --web-renderer canvaskit --base-href "/"
