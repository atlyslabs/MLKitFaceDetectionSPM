#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/Frameworks"

INFO_PLIST_TEMPLATE() {
  local bundle_name="$1"
  cat <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${bundle_name}</string>
    <key>CFBundleIdentifier</key>
    <string>com.google.mlkit.${bundle_name}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${bundle_name}</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
PLIST
}

add_info_plist() {
  local framework_path="$1"
  local bundle_name
  bundle_name="$(basename "$framework_path" .framework)"
  INFO_PLIST_TEMPLATE "$bundle_name" > "${framework_path}/Info.plist"
}

build_standard_xcframework() {
  local fw="$1"
  local work="/tmp/mlkit_xcf_${fw}"
  rm -rf "$work"
  mkdir -p "$work/device/${fw}.framework" "$work/simulator/${fw}.framework"
  cp -R "${ROOT_DIR}/${fw}.framework/"* "$work/device/${fw}.framework/"
  cp -R "${ROOT_DIR}/${fw}.framework/"* "$work/simulator/${fw}.framework/"
  lipo "${ROOT_DIR}/${fw}.framework/${fw}" -thin arm64 -output "$work/device/${fw}.framework/${fw}"
  lipo "${ROOT_DIR}/${fw}.framework/${fw}" -thin x86_64 -output "$work/simulator/${fw}.framework/${fw}"
  add_info_plist "$work/device/${fw}.framework"
  add_info_plist "$work/simulator/${fw}.framework"
  rm -rf "${OUT_DIR}/${fw}.xcframework"
  xcodebuild -create-xcframework \
    -framework "$work/device/${fw}.framework" \
    -framework "$work/simulator/${fw}.framework" \
    -output "${OUT_DIR}/${fw}.xcframework"
}

build_face_detection_xcframework() {
  local fw="MLKitFaceDetection"
  local out="${OUT_DIR}/${fw}.xcframework"
  rm -rf "$out"
  for variant in ios-arm64 ios-x86_64-simulator; do
    if [ "$variant" = "ios-arm64" ]; then
      arch=arm64
    else
      arch=x86_64
    fi
    local dest="$out/$variant/${fw}.framework"
    mkdir -p "$dest"
    cp -R "${ROOT_DIR}/${fw}.framework/Headers" "$dest/"
    cp -R "${ROOT_DIR}/${fw}.framework/Modules" "$dest/"
    cp "${ROOT_DIR}/${fw}.framework/PrivacyInfo.xcprivacy" "$dest/"
    cp -R "${ROOT_DIR}/${fw}.framework/GoogleMVFaceDetectorResources.bundle" "$dest/"
    lipo "${ROOT_DIR}/${fw}.framework/${fw}" -thin "$arch" -output "$dest/${fw}"
    add_info_plist "$dest"
  done
  cat > "$out/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AvailableLibraries</key>
	<array>
		<dict>
			<key>BinaryPath</key>
			<string>${fw}.framework/${fw}</string>
			<key>LibraryIdentifier</key>
			<string>ios-x86_64-simulator</string>
			<key>LibraryPath</key>
			<string>${fw}.framework</string>
			<key>SupportedArchitectures</key>
			<array><string>x86_64</string></array>
			<key>SupportedPlatform</key>
			<string>ios</string>
			<key>SupportedPlatformVariant</key>
			<string>simulator</string>
		</dict>
		<dict>
			<key>BinaryPath</key>
			<string>${fw}.framework/${fw}</string>
			<key>LibraryIdentifier</key>
			<string>ios-arm64</string>
			<key>LibraryPath</key>
			<string>${fw}.framework</string>
			<key>SupportedArchitectures</key>
			<array><string>arm64</string></array>
			<key>SupportedPlatform</key>
			<string>ios</string>
		</dict>
	</array>
	<key>CFBundlePackageType</key>
	<string>XFWK</string>
	<key>XCFrameworkFormatVersion</key>
	<string>1.0</string>
</dict>
</plist>
PLIST
}

mkdir -p "$OUT_DIR"
for fw in MLImage MLKitCommon MLKitVision; do
  echo "Building ${fw}.xcframework"
  build_standard_xcframework "$fw"
done

echo "Building MLKitFaceDetection.xcframework"
build_face_detection_xcframework

echo "Done."
