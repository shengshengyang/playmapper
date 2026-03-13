#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] flutter command not found. Please install Flutter SDK first." >&2
  exit 1
fi

echo "[INFO] Generating iOS/macOS host projects..."
flutter create . --platforms=ios,macos

IOS_PLIST="ios/Runner/Info.plist"
if [[ -f "$IOS_PLIST" ]]; then
  if ! grep -q "NSLocationWhenInUseUsageDescription" "$IOS_PLIST"; then
    /usr/libexec/PlistBuddy -c "Add :NSLocationWhenInUseUsageDescription string 使用定位以顯示目前位置" "$IOS_PLIST" || true
  fi
  if ! grep -q "NSLocationAlwaysAndWhenInUseUsageDescription" "$IOS_PLIST"; then
    /usr/libexec/PlistBuddy -c "Add :NSLocationAlwaysAndWhenInUseUsageDescription string 使用定位以規劃親子路線" "$IOS_PLIST" || true
  fi
fi

echo "[INFO] Done. You can now run:"
echo "  flutter run -d ios --dart-define=API_BASE_URL=http://localhost:8080"
echo "  flutter run -d macos --dart-define=API_BASE_URL=http://localhost:8080"
