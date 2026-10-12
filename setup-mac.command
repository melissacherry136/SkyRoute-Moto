#!/bin/bash
# SkyRoute — one-time Mac setup. Right-click this file → Open (or: bash setup-mac.command).
# Installs Node.js + CocoaPods via Homebrew, prepares the iOS project, and opens it in Xcode.
set -e
cd "$(dirname "$0")"
echo "=== SkyRoute Mac setup ==="

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode command-line tools are missing — a dialog will appear; click Install, then run this file again."
  xcode-select --install || true
  exit 0
fi
echo "Accepting the Xcode license (you may be asked for your Mac password)..."
sudo xcodebuild -license accept || true
sudo xcodebuild -runFirstLaunch || true

if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
  echo "Installing Homebrew (package manager) — press Return when it asks, and type your Mac password if prompted..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"

echo "Installing Node.js and CocoaPods..."
brew install node cocoapods

echo "Installing the app's build tools..."
npm install
npx esbuild src/native.js --bundle --minify --format=iife --outfile=www/native.js
npx cap sync ios

echo "Installing iOS dependencies..."
if [ -f ios/App/Podfile ]; then (cd ios/App && pod install); fi

echo
echo "=== Done. Opening the project in Xcode. ==="
if [ -d ios/App/App.xcworkspace ]; then open ios/App/App.xcworkspace; else open ios/App/App.xcodeproj; fi
echo "In Xcode: pick your iPhone (or an iPhone simulator) in the top bar, then press the Play button."
read -n 1 -s -r -p "Press any key to close this window."
