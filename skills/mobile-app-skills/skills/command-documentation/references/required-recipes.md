# Required recipes: device install and DEX inspection

Every Android portfolio app must carry these recipes in **both** its
`README.md` and `docs/commands.md`, below the Flutter run and build commands
and next to its Shorebird release/patch recipes. They are copied from Gravity
Rolling Launcher's `docs/commands.md` (November 2026) as the reference wording.
Adapt paths, version examples and the score threshold to the app; keep the
templates' placeholders and the password-file handling.

If the app does not yet have `tool/check_dex_optimization.py`, copy
[tools/check_dex_optimization.py](tools/check_dex_optimization.py) into the
app's `tool/` folder. Its 25% threshold is Gravity's reported minimum; set the
app's own.

## Inspect release DEX optimization

From the app root, with Python 3, inspect the exact AAB produced by the chosen
Flutter or Shorebird release command:

```sh
python3 tool/check_dex_optimization.py build/app/outputs/bundle/release/app-release.aab
```

This reads the bundle's R8 metadata, reports its SHA-256, uncompressed DEX size
and optimization/obfuscation/shrinking scores, and exits nonzero for disabled R8
options, missing/invalid metadata or any raw score below this app's reported 25%
minimum. It does not build, install, modify or upload anything. A passing score
does not establish runtime safety or Play Console clearance. Native rule/theme
changes require a new store release; a Shorebird Dart patch cannot carry them.


## Test an existing Shorebird release bundle on a device

Use the exact AAB already produced by the intended `shorebird release`; do not
run a separate Flutter release build to test that baseline. Android installs
APKs generated from the AAB. The conversion below uses Shorebird's cached
`bundletool` and the existing signing identity without recompiling app code or
replacing the source AAB.

Run from the app root with Java 17 and Android SDK Platform Tools (`adb`) on
PATH, and a USB/wireless-debugging phone authorized. These are templates:
replace `SHOREBIRD_RELEASE_AAB`, `CURRENT_DEVICE_ID`, `KEYSTORE_PATH` and `KEY_ALIAS`
with the intended existing bundle, device ID and signing identity. Replace
`KS_PASSWORD_FILE` and `KEY_PASSWORD_FILE` with private, temporary files containing
the respective passwords; keep those files out of the repository and delete
them afterwards. Do not put passwords directly in command arguments.

```sh
adb devices -l
mkdir -p output
java -Xmx1G -jar "$HOME/.shorebird/bin/cache/artifacts/bundletool/bundletool.jar" build-apks --bundle=SHOREBIRD_RELEASE_AAB --output=output/shorebird-device-test.apks --connected-device --device-id=CURRENT_DEVICE_ID --ks=KEYSTORE_PATH --ks-key-alias=KEY_ALIAS --ks-pass=file:KS_PASSWORD_FILE --key-pass=file:KEY_PASSWORD_FILE
java -Xmx1G -jar "$HOME/.shorebird/bin/cache/artifacts/bundletool/bundletool.jar" install-apks --apks=output/shorebird-device-test.apks --device-id=CURRENT_DEVICE_ID
```

Use a fresh `.apks` output filename for another device or conversion. The
commands create device-specific APKs from the supplied bundle and install its
matching splits. They preserve a matching installed app's data. Resolve any
signature mismatch without uninstalling the user's existing app. They do not
publish/upload a release, change the default launcher, or start the app.

The source AAB remains the artifact to upload to Play. Device APKs contain the
same compiled app and assets from that bundle; local APK signing uses the supplied
key, while Play App Signing may use a different distribution certificate.

### Install an uploaded release with `shorebird preview`

`shorebird preview` is the shorter route when the release has already been
uploaded to Shorebird. It downloads that release's artifact, converts it with
the cached `bundletool` and installs it, so it does not need a local AAB and
does not read `build/app/outputs/bundle/`. Use the `bundletool` commands above
instead when the exact bundle on disk is the thing under test, or when the
release was never uploaded.

Template: replace `RELEASE_VERSION` (`1.0.2+3` form), `CURRENT_DEVICE_ID`,
`KEYSTORE_PATH` and `KEY_ALIAS`, and point the password flags at private,
temporary files kept out of the repository and deleted afterwards. Without the
signing flags `bundletool` signs with a debug key, which will not match an
installed store build.

```sh
adb devices -l
shorebird preview --platform=android --release-version=RELEASE_VERSION --device-id=CURRENT_DEVICE_ID --ks=KEYSTORE_PATH --ks-key-alias=KEY_ALIAS --ks-pass=file:KS_PASSWORD_FILE --ks-key-pass=file:KEY_PASSWORD_FILE
```

Omitting `--release-version` makes the CLI prompt for a release. The command
downloads and installs; it does not publish, patch or upload anything.

