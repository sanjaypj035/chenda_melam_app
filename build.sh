#!/bin/bash

set -e  # Exit immediately on error

# Download and extract Flutter 3.22.2
FLUTTER_VERSION="3.22.2"
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Use local Flutter path
FLUTTER_PATH="$(pwd)/flutter/bin/flutter"

# Fix Git safe directory issue
git config --global --add safe.directory /vercel/path0

# Disable Flutter analytics
$FLUTTER_PATH config --no-analytics

# Show Flutter version
$FLUTTER_PATH --version

# Get dependencies
$FLUTTER_PATH pub get

# Build web app
$FLUTTER_PATH build web --release --web-renderer canvaskit --base-href "/"
