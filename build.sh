#!/bin/bash

cd src/swift
# Build the Swift terminal notifier
echo "Building cursor-agent-notifier..."

# Clean up any previous builds
rm -rf cursor-agent-notifier.app
rm -f cursor-agent-notifier

# Build using Swift Package Manager
swift build -c release

# Create the .app bundle structure
echo "Creating .app bundle..."
mkdir -p cursor-agent-notifier.app/Contents/MacOS
mkdir -p cursor-agent-notifier.app/Contents/Resources

# Copy the Info.plist
cp Info.plist cursor-agent-notifier.app/Contents/

# Copy the icon
cp ../assets/Cursor.icns cursor-agent-notifier.app/Contents/Resources/

# Copy the executable to the proper location in the .app bundle
cp .build/release/cursor-agent-notifier cursor-agent-notifier.app/Contents/MacOS/

# Make the executable... executable
chmod +x cursor-agent-notifier.app/Contents/MacOS/cursor-agent-notifier

# Code sign the app bundle
echo "Code signing the app bundle..."
codesign --force --deep --sign - cursor-agent-notifier.app

# ensure dist directory exists
mkdir -p ../../dist

mv cursor-agent-notifier.app ../../dist/cursor-agent-notifier.app

echo "Build complete!"
echo "Usage examples:"
echo "  ./cursor-agent-notifier.app/Contents/MacOS/cursor-agent-notifier -title \"Test\" -subtitle \"Subtitle\" -message \"Message\""