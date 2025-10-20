#!/usr/bin/env bash
set -euo pipefail

# High-level automation that mirrors the end-to-end workflow the README describes:
#  - build a debug (or release) APK using tool/build_test_apk.sh
#  - upload it to Firebase App Distribution
#  - invite testers by e-mail or tester groups
#
# The script assumes the Firebase CLI is already authenticated via `firebase login`.

MODE="debug"
OFFLINE=0
SKIP_DOCTOR=0
APK_OVERRIDE=""
FIREBASE_APP_ID=""
TESTERS=""
GROUPS=""
RELEASE_NOTES=""
RELEASE_NOTES_FILE=""
DRY_RUN=0
KEEP_NOTES_FILE=0
BUILD_SCRIPT_ARGS=()

usage() {
  cat <<USAGE
Usage: $0 [options]
  --app <firebase-app-id>        Firebase Android app ID (looks like 1:1234567890:android:abc123).
  --testers <emails>             Comma-separated list of tester email addresses.
  --groups <group-aliases>       Comma-separated Firebase tester groups (optional).
  --release-notes <text>         Short release notes text (optional).
  --release-notes-file <path>    File containing release notes (alternative to --release-notes).
  --apk <path>                   Use an existing APK instead of rebuilding.
  --release                      Build a release APK (default is debug).
  --offline                      Pass --offline to Flutter commands during the build.
  --no-doctor                    Skip running flutter doctor in the build helper.
  --build-arg <arg>              Forward an additional argument to build_test_apk.sh (repeatable).
  --dry-run                      Show the firebase command without executing it.
  -h, --help                     Show this help message.

Examples:
  $0 --app 1:123:android:abc --testers alice@example.com,bob@example.com
  $0 --app 1:123:android:abc --groups qa-team --release --release-notes "Smoke test"
USAGE
}

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$1"
}

die() {
  printf '\033[1;31mERROR:\033[0m %s\n' "$1" >&2
  exit 1
}

warn() {
  printf '\033[1;33mWARN:\033[0m %s\n' "$1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app)
      [[ $# -gt 1 ]] || die "--app requires an argument"
      FIREBASE_APP_ID="$2"
      shift
      ;;
    --testers)
      [[ $# -gt 1 ]] || die "--testers requires a comma-separated list"
      TESTERS="$2"
      shift
      ;;
    --groups)
      [[ $# -gt 1 ]] || die "--groups requires an argument"
      GROUPS="$2"
      shift
      ;;
    --release-notes)
      [[ $# -gt 1 ]] || die "--release-notes requires text"
      RELEASE_NOTES="$2"
      shift
      ;;
    --release-notes-file)
      [[ $# -gt 1 ]] || die "--release-notes-file requires a path"
      RELEASE_NOTES_FILE="$2"
      shift
      ;;
    --apk)
      [[ $# -gt 1 ]] || die "--apk requires a path"
      APK_OVERRIDE="$2"
      shift
      ;;
    --release)
      MODE="release"
      ;;
    --offline)
      OFFLINE=1
      ;;
    --no-doctor)
      SKIP_DOCTOR=1
      ;;
    --build-arg)
      [[ $# -gt 1 ]] || die "--build-arg requires a value"
      BUILD_SCRIPT_ARGS+=("$2")
      shift
      ;;
    --dry-run)
      DRY_RUN=1
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

[[ -f pubspec.yaml ]] || die "Run this script from the repository root (pubspec.yaml missing)."

if [[ -z "$APK_OVERRIDE" ]]; then
  BUILD_SCRIPT=("$PROJECT_ROOT/tool/build_test_apk.sh")
  [[ -x "${BUILD_SCRIPT[0]}" ]] || die "${BUILD_SCRIPT[0]} is not executable."
  if [[ $MODE == "release" ]]; then
    BUILD_SCRIPT+=(--release)
  else
    BUILD_SCRIPT+=(--debug)
  fi
  if [[ $OFFLINE -eq 1 ]]; then
    BUILD_SCRIPT+=(--offline)
  fi
  if [[ $SKIP_DOCTOR -eq 1 ]]; then
    BUILD_SCRIPT+=(--no-doctor)
  fi
  BUILD_SCRIPT+=("${BUILD_SCRIPT_ARGS[@]}")

  log "Building ${MODE} APK via tool/build_test_apk.sh"
  "${BUILD_SCRIPT[@]}"

  if [[ $MODE == "release" ]]; then
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
  else
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
  fi
  if [[ ! -f "$APK_PATH" ]]; then
    die "Expected APK not found at $APK_PATH. Check the build output above."
  fi
else
  APK_PATH="$APK_OVERRIDE"
  [[ -f "$APK_PATH" ]] || die "APK override path '$APK_PATH' does not exist."
  log "Using pre-built APK at $APK_PATH"
fi

[[ -n "$FIREBASE_APP_ID" ]] || die "--app is required."
if [[ -z "$TESTERS" && -z "$GROUPS" ]]; then
  warn "No testers or groups specified. Firebase will accept the upload but no one will be notified."
fi

command -v firebase >/dev/null 2>&1 || die "Firebase CLI not found in PATH. Install it and run 'firebase login' first."

CMD=(firebase appdistribution:distribute "$APK_PATH" --app "$FIREBASE_APP_ID")

if [[ -n "$TESTERS" ]]; then
  CMD+=(--testers "$TESTERS")
fi
if [[ -n "$GROUPS" ]]; then
  CMD+=(--groups "$GROUPS")
fi

cleanup_notes() {
  if [[ -n "$RELEASE_NOTES_FILE" && $KEEP_NOTES_FILE -eq 0 ]]; then
    rm -f "$RELEASE_NOTES_FILE"
  fi
}

if [[ -n "$RELEASE_NOTES" ]]; then
  RELEASE_NOTES_FILE="$(mktemp)"
  KEEP_NOTES_FILE=0
  printf '%s' "$RELEASE_NOTES" > "$RELEASE_NOTES_FILE"
  CMD+=(--release-notes-file "$RELEASE_NOTES_FILE")
elif [[ -n "$RELEASE_NOTES_FILE" ]]; then
  [[ -f "$RELEASE_NOTES_FILE" ]] || die "Release notes file '$RELEASE_NOTES_FILE' does not exist."
  KEEP_NOTES_FILE=1
  CMD+=(--release-notes-file "$RELEASE_NOTES_FILE")
fi

trap cleanup_notes EXIT

log "Firebase upload command: ${CMD[*]}"

if [[ $DRY_RUN -eq 1 ]]; then
  log "Dry run enabled; not executing Firebase CLI command."
  exit 0
fi

"${CMD[@]}"
log "Firebase App Distribution upload complete."
