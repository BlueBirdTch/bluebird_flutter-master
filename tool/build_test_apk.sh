#!/usr/bin/env bash
set -euo pipefail

# Simple helper that mirrors the manual steps for producing a test APK.
# Usage: ./tool/build_test_apk.sh [--debug|--release] [--offline] [--no-doctor]

MODE="debug"
RUN_DOCTOR=1
OFFLINE=0

usage() {
  cat <<USAGE
Usage: $0 [options]
  --debug            Build a debug APK (default).
  --release          Build a release APK.
  --offline          Pass --offline to flutter commands.
  --no-doctor        Skip running flutter doctor at the start.
  -h, --help         Show this message.

The script must be run from within the Flutter project root where pubspec.yaml
is located. It will run flutter pub get, optionally flutter doctor, and then
invoke flutter build apk with the requested build mode.
USAGE
}

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$1"
}

warn() {
  printf '\033[1;33mWARN:\033[0m %s\n' "$1"
}

die() {
  printf '\033[1;31mERROR:\033[0m %s\n' "$1" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug)
      MODE="debug"
      ;;
    --release)
      MODE="release"
      ;;
    --offline)
      OFFLINE=1
      ;;
    --no-doctor)
      RUN_DOCTOR=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$PROJECT_ROOT"

[[ -f pubspec.yaml ]] || die "pubspec.yaml not found. Run the script from the project root."
command -v flutter >/dev/null 2>&1 || die "flutter command not found in PATH. Install Flutter first."

flutter_version() {
  flutter --version 2>/dev/null | head -n 1 || true
}

log "Flutter SDK: $(flutter_version)"

if [[ $RUN_DOCTOR -eq 1 ]]; then
  log "Running flutter doctor (use --no-doctor to skip)"
  flutter doctor || warn "flutter doctor reported issues. Check the output above if the build fails."
fi

FLUTTER_FLAGS=()
if [[ $OFFLINE -eq 1 ]]; then
  FLUTTER_FLAGS+=(--offline)
fi

# Track files we temporarily patch so we can restore them automatically.
PATCHED_FILES=()
cleanup() {
  for f in "${PATCHED_FILES[@]:-}"; do
    if [[ -f "$f.bak" ]]; then
      mv "$f.bak" "$f"
    fi
  done
}
trap cleanup EXIT

strip_google_services_if_missing() {
  if find android/app -name google-services.json -print -quit 2>/dev/null | grep -q .; then
    return
  fi

  local gradle_files=("android/app/build.gradle" "android/app/build.gradle.kts")
  local changed=0
  for g in "${gradle_files[@]}"; do
    if [[ -f "$g" ]]; then
      cp "$g" "$g.bak"
      PATCHED_FILES+=("$g")
      sed -i -E 's/^(\s*)(apply plugin:\s*"com\.google\.gms\.google-services")/\1\/\/ \2/' "$g" 2>/dev/null || true
      sed -i -E 's/^(\s*)(id\(\s*"com\.google\.gms\.google-services"\s*\))/\1\/\/ \2/' "$g" 2>/dev/null || true
      sed -i -E '/com\.google\.gms\.google-services/d' "$g" 2>/dev/null || true
      changed=1
    fi
  done

  if [[ $changed -eq 1 ]]; then
    warn "google-services.json not found. Temporarily disabled the Google Services plugin for this build."
  fi
}

strip_google_services_if_missing

log "Fetching Flutter packages"
flutter pub get "${FLUTTER_FLAGS[@]}"

log "Building $MODE APK"
flutter build apk --$MODE "${FLUTTER_FLAGS[@]}"

APK_PATH="build/app/outputs/flutter-apk/app-${MODE}.apk"
if [[ ! -f "$APK_PATH" ]]; then
  # Release builds sometimes output app-release.apk regardless of mode naming conventions
  ALT_PATH="build/app/outputs/flutter-apk/app-release.apk"
  if [[ -f "$ALT_PATH" ]]; then
    APK_PATH="$ALT_PATH"
  else
    die "APK not found at expected location. Check the build output for details."
  fi
fi

log "APK ready: $PROJECT_ROOT/$APK_PATH"
log "Upload this file to Firebase App Distribution or sideload it on a device for testing."
