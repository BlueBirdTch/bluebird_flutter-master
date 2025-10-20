# Bluebird

Bluebird is a Flutter application. This repository now includes a helper script
that automates the steps for producing installable APKs for internal testing or
Firebase App Distribution.

## Prerequisites

Before building the app you need the following tools installed locally:

- [Flutter](https://flutter.dev/docs/get-started/install) (the project is tested
  with Flutter 3.x)
- Android SDK/command-line tools and a recent JDK (11 or newer)
- `git` and common Unix utilities available on your shell (`bash`, `sed`,
  `find`)

You can confirm your setup with `flutter doctor`.

## Quick start

```bash
# Install dependencies
flutter pub get

# Run the application on a connected device or emulator
flutter run
```

## Build a test APK automatically

Use the `tool/build_test_apk.sh` script for a one-command build that mirrors the
manual steps discussed in the project docs. The script will:

1. Check that Flutter is available
2. Optionally run `flutter doctor`
3. Run `flutter pub get`
4. Temporarily disable the Google Services plugin when
   `google-services.json` is absent so the build can succeed without Firebase
   configuration
5. Invoke `flutter build apk` in the requested mode (debug by default)
6. Print the path to the generated APK

Run it from the repository root:

```bash
./tool/build_test_apk.sh                 # debug build (default)
./tool/build_test_apk.sh --release       # release build
./tool/build_test_apk.sh --offline       # reuse cached packages
./tool/build_test_apk.sh --install       # build + install on the first adb device
./tool/build_test_apk.sh --device <id>   # build + install on a specific adb device
./tool/build_test_apk.sh            # debug build (default)
./tool/build_test_apk.sh --release  # release build
./tool/build_test_apk.sh --offline  # reuse cached packages
```

After the script finishes, you will find the artifact at
`build/app/outputs/flutter-apk/app-debug.apk` (or `app-release.apk` for release
builds). Upload this file to Firebase App Distribution or sideload it on a test
device.

### Build and push to Firebase in one command

If you would like the script to build the APK *and* ship it to Firebase App
Distribution (including sending tester invites), use
`tool/build_and_distribute.sh`. Before running it, install the
[Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli),
log in with `firebase login`, and note the Firebase Android app ID from the
console (it looks like `1:1234567890:android:abc123`).

Run the script from the repository root:

```bash
./tool/build_and_distribute.sh \
  --app <firebase-android-app-id> \
  --testers "skannepa2206@gmail.com,bluebirdsriram@gmail.com" \
  --release-notes "Smoke test build"
```

Key flags:

- `--release` builds a release APK instead of the default debug build.
- `--groups` lets you target Firebase tester groups in addition to, or instead
  of, individual e-mail addresses.
- `--apk` skips the build step and distributes an existing APK file.
- `--dry-run` prints the Firebase CLI command without executing it—useful for
  validation before a real upload.

The script invokes `tool/build_test_apk.sh` under the hood (unless you pass
`--apk`), then runs `firebase appdistribution:distribute` with the options you
specified. It prints the exact Firebase CLI command before executing it so you
can see what will happen.

### Install directly on your phone

1. Enable **Developer options** and **USB debugging** on your Android device.
2. Connect the device to your computer and verify it is visible to the Android
   SDK with `adb devices`.
3. Run `./tool/build_test_apk.sh --install` to build the debug APK and push it
   to the connected device automatically. If multiple devices are connected,
   pass `--device <serial>` to pick the target shown by `adb devices`.
4. Unlock the phone and confirm the installation prompt if required.

You can still take the generated APK and upload it to Firebase App Distribution
for remote testers.

## Manual build (optional)

If you prefer to run the steps yourself:

```bash
flutter doctor
flutter pub get
flutter build apk --debug
```

Release builds require configuring a proper signing key in
`android/app/build.gradle` before distributing outside your team.
