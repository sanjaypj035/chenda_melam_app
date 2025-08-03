#!/bin/bash
set -e

# Define Flutter version
FLUTTER_VERSION="3.22.2"

# Download Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Define Flutter binary path
FLUTTER="./flutter/bin/flutter"

# Mark Flutter directory as safe before doing anything else
git config --global --add safe.directory "$(pwd)/flutter"

# Disable analytics
$FLUTTER config --no-analytics

# Print Flutter version
$FLUTTER --version

# Install dependencies
$FLUTTER pub get

# Build the web app
$FLUTTER build web --release --web-renderer canvaskit --base-href "/"

# Optional: prepare Vercel output (not needed if using distDir in vercel.json)
