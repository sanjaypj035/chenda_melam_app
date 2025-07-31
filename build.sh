#!/bin/bash
# Install Flutter dependencies
flutter pub get

# Build the Flutter web application
flutter build web --release --web-renderer canvaskit --base-href /

# Copy the built files to the output directory
cp -r build/web/* .
