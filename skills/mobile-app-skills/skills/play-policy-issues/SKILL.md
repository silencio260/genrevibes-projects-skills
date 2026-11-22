---
name: play-policy-issues
description: "Known Google Play Console review blockers and warnings, with their fixes, plus the production-ready check to run before every Play upload (hardware features, DEX optimization score)."
---

# Known Play policy issues and the production-ready check

Use this when Play Console refuses to send a release for review, shows a
pre-review warning, or when the owner asks for a **production-ready check**
before an upload. Every case below happened in a portfolio app. Run the whole
[production-ready check](#production-ready-check) on every release, not only
the case that was reported, so a fixed issue can't come back.

## Production-ready check

Run after the release build the owner made, against that exact artifact.
Don't build, install or upload unless the owner asked.

1. **Version.** `pubspec.yaml` `version:` is higher than the last Play
   release, in both the name and the build number.
2. **Hardware features.** No `<uses-feature>` is required, declared or
   implied. See [Required hardware features](#required-hardware-features-block-review).
3. **DEX optimization score.** All three R8 scores are at least 25%. See
   [Low DEX optimization score](#low-dex-optimization-score).
4. **Native SDK adapters.** Revenue adapters the app relies on are in the
   resolved dependencies (for Appodeal → Firebase, see
   [Appodeal Firebase revenue](../../references/appodeal-firebase-revenue.md)).
5. **Languages.** The languages the app means to offer are enabled in release
   in all three places: the Dart locale catalogue, Android's main
   `res/xml/locales_config.xml` (not only the debug one) and iOS
   `CFBundleLocalizations`. A debug-only gate silently ships English only.
6. **Report** each item as passed, fixed, or not checked (with why). A native
   manifest or Gradle fix needs a new store build; a Shorebird patch can't
   carry it.

## Required hardware features block review

### Recorded incident: Gravity Rolling Icon Launcher, release 6 (1.0.5), 22 November 2026

Play refused to send the release for review:

> Required hardware feature declarations are restricting your app's availability

It listed `android.hardware.screen.landscape`, `android.hardware.screen.portrait`
and `android.hardware.wifi`, each affecting phone, tablet, desktop and
Android XR users.

### Cause

The app never declared them. Play **infers** required features from the merged
manifest, and an inferred feature is required unless the app says otherwise:

| Inferred feature | Comes from |
|---|---|
| `android.hardware.wifi` | `ACCESS_WIFI_STATE` / `CHANGE_WIFI_STATE`, added by ad SDKs |
| `android.hardware.screen.portrait` | an activity with `screenOrientation="portrait"` (Appodeal/IAB, myTarget, Bigo ad activities) |
| `android.hardware.screen.landscape` | an activity with `screenOrientation="landscape"` (same SDKs) |

Camera, location, telephony and bluetooth permissions are inferred the same way.

### Fix

In the app's `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:

```xml
<uses-feature android:name="android.hardware.screen.portrait" android:required="false"/>
<uses-feature android:name="android.hardware.screen.landscape" android:required="false"/>
<uses-feature android:name="android.hardware.wifi" android:required="false"/>
```

Add one line per inferred feature the app can work without. Don't change SDK
activities' orientation.

### Check

```bash
grep -n -A2 "uses-feature" build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml
```

Every entry must say `android:required="false"`. For what Play will infer,
run `aapt2 dump badging` on a release APK from the same code (it reads APKs,
not AABs) and look at `uses-feature` and `uses-implied-feature` lines.

## Low DEX optimization score

### Recorded incident: Gravity Rolling Icon Launcher, release 5 (1.0.4), November 2026

Play reported 22–23% obfuscation (target 25%) although R8 full shrinking was
on. The 2026-11-18 mapping had 56,673 classes, 21% renamed; 10,706 unrenamed
classes were `com.google.android.gms.*`.

### Cause

Ad adapters ship consumer ProGuard rules with blanket keeps of all of Play
Services, for example:

- `com.appodeal.ads.sdk.adapters:inmobi` / `:vungle`
- `com.applovin.mediation:inmobi-adapter` / `vungle-adapter`
- `org.bidon:inmobi-adapter:11.3.0.0` and `org.bidon:vungle-adapter:7.7.4.0`
  (pulled in by Appodeal; missed by the first audit)

with rules like `-keep class com.google.android.gms.** { *; }`.

### Fix

Replace those exact adapters' consumer rules instead of removing adapters:

1. Copy each adapter's complete `proguard.txt` from the Gradle cache into
   `android/app/proguard/<adapter>-<version>.pro`, record the original SHA-256
   in a header, and delete **only** the blanket Google keep line.
2. In `android/app/build.gradle.kts`, map those exact coordinates and filter
   their vendor rules:

   ```kotlin
   val consumerRuleOverrides = mapOf(
       "org.bidon:vungle-adapter:7.7.4.0" to "proguard/bidon-vungle-7.7.4.0.pro",
       // ...one entry per audited adapter
   )
   // release buildType:
   optimization { keepRules { ignoreFrom(*consumerRuleOverrides.keys.toTypedArray()) } }
   consumerRuleOverrides.values.forEach { proguardFile(it) }
   ```
3. Keep narrower Google keeps (`gms.ads.**`, `common`, `tasks`, `appset`,
   `ads.identifier`, `ump`) and the SDKs' own package keeps, which they need
   for reflection.

A new adapter version falls back to its vendor rules: re-audit after every
mediation upgrade.

### Check

```bash
python3 tool/check_dex_optimization.py build/app/outputs/bundle/release/app-release.aab
```

It prints the optimization, obfuscation and shrinking scores from the AAB's
R8 metadata. Below 25%, find remaining blanket keeps in
`build/app/outputs/mapping/release/configuration.txt`
(`grep -n "com.google.android.gms.\*\*"`) and trace each to its library. Then
cold-start the release and check Firebase, Crashlytics, consent and each ad
format, since a score pass doesn't prove runtime safety. For Appodeal/MAX/Unity
cases see [Android mediation optimization](../android-mediation-optimization/SKILL.md).

## Adding a new case

When Play reports something new: record the exact Play text, the app and
release, the cause proven from the artifact, the fix, and a command that checks
it. Then add that check to the [production-ready check](#production-ready-check).
