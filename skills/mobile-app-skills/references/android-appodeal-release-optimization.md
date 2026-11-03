# Appodeal release DEX optimization with many enabled networks

## When this case applies

Lunaris Network's October 2026 release used Appodeal with many network adapters
and bridges enabled. Play Console showed low DEX optimization even though full
R8 and resource shrinking were already enabled. Broad third-party consumer
keeps also protected shared Google, ExoPlayer and Protobuf code used elsewhere
in the app. Narrowing audited rules improved scores while preserving all
enabled networks and bridges.

This is a version-specific case, not permission to remove SDK rules wholesale.
Resolve the target app's dependencies and inspect their actual AARs first.
For startup crashes matching the earlier Room failure, read
[known release issues](android-known-release-issues.md). For memory exhaustion,
use the [release build skill](../skills/android-release-build-experiment/SKILL.md).

## Recorded environment and results

Lunaris used AGP 9.0.1, R8 9.0.32, Flutter 3.44.1 via Shorebird (revision
`26ad1cdf21`), a 4 GB Gradle heap and two workers. These were unchanged during
the optimization. The Protobuf Lite runtime resolved to `protobuf-javalite:3.25.6`.

| Revision | Optimization | Obfuscation | Shrinking |
|---|---:|---:|---:|
| Baseline, 1.0.1+3 | 19.94% | 20.06% | 27.85% |
| Four Google-rule overrides | 23.14% | 23.26% | 31.37% |
| Add myTarget legacy ExoPlayer override | 23.95% | 24.07% | 32.66% |
| Add Protobuf narrowing, 1.0.2+4 | 25.06% | 25.16% | 34.12% |

The first two dry runs failed the packaged-score gate. The final dry run
completed with exit 0 and Shorebird's `No issues detected`. Uncompressed DEX
fell from 50,691,148 to 45,314,860 bytes; the final AAB was 101,637,305 bytes.
Its SHA-256 was:

```text
50090dfe1b4437009e30dcc474089c3f459bf8a432a529b0e2d93f77498eeb4c
```

The recorded minimum was 25% in all three categories for this app's DEX size.
The optimization/obfuscation margin is small. Recheck current Play requirements
and actual new artifact scores when applying this guidance; these figures are
historical measurements, not guaranteed results for another dependency graph.

## Trace restrictions to their owners

Resolve `releaseRuntimeClasspath`, including transitive MAX/other bridge
adapters. For example, from the app's Android directory:

```sh
./gradlew :app:dependencies --configuration releaseRuntimeClasspath
./gradlew :app:dependencyInsight --configuration releaseRuntimeClasspath --dependency protobuf-javalite
```

These are dependency diagnostics, not application release builds, although
Gradle may compile build logic. Read the existing AAB metadata and the matching
`build/app/outputs/mapping/release/` files. The baseline seeds listed 41,766
kept Google Play Services classes/members out of 459,563 kept entries. Counts
help locate restrictions; they do not predict the final optimization scores.

Extract consumer rules from each resolved AAR, including any embedded JAR rules.
Match broad merged rules to their source. Inspect the library that a rule
protects as well as the SDK supplying it: class references alone do not rule
out reflection, string names or JNI dependencies.

## Six scoped replacements used in Lunaris

Each replacement started as the complete original AAR `proguard.txt`, with its
coordinate and original rule-file SHA-256 recorded in the header. Only the
following eight blanket blocks were removed across these six files:

| Exact dependency | Host replacement under `android/app/proguard/` | Removed protection |
|---|---|---|
| `com.appodeal.ads.sdk.adapters:inmobi:11.3.0.0` | `appodeal-inmobi-11.3.0.0.pro` | `-keep public class com.google.android.gms.**` |
| `com.appodeal.ads.sdk.adapters:my_target:5.51.2.0` | `appodeal-mytarget-5.51.2.0.pro` | `-keep class com.google.android.exoplayer2.** { *; }` |
| `com.appodeal.ads.sdk.adapters:vungle:7.7.4.0` | `appodeal-vungle-7.7.4.0.pro` | `-keep class com.google.android.gms.** { *; }`; `-keepclassmembers class com.google.protobuf.** { *; }`; `-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }` |
| `com.applovin.mediation:inmobi-adapter:11.3.0.1` | `max-inmobi-11.3.0.1.pro` | `-keep public class com.google.android.gms.**` |
| `com.applovin.mediation:vungle-adapter:7.7.4.0` | `max-vungle-7.7.4.0.pro` | `-keep class com.google.android.gms.internal.** { *; }` |
| `com.unity3d.ads:unity-ads:4.17.0` | `unity-ads-4.17.0.pro` | `-keep public class com.google.protobuf.** { *; }` |

The table identifies removed blocks, not complete safe replacement files.
Reconstruct replacements from the resolved source AARs and preserve their
remaining rules. Do not supply only the rules in the next section after
filtering a dependency's consumers.

Lunaris' Kotlin DSL used a `consumerRuleOverrides` map of these exact coordinates
to the corresponding host files. Inside `buildTypes.release`:

```kotlin
optimization.keepRules {
    ignoreFrom(*consumerRuleOverrides.keys.toTypedArray())
}
consumerRuleOverrides.values.forEach { proguardFile(it) }
```

Check the target AGP's API before using this syntax. Filter exact versions only.
Upgraded dependencies must fall back to their vendor rules until re-audited.
Keep other dependencies' consumers enabled. Inspect the resulting merged
`configuration.txt` to confirm the replacements actually loaded and that another
adapter has not reintroduced the same blanket keep.

### Why these particular changes were justified

The Google-wide rules constrained unrelated Firebase/Play Services code. Google
libraries' own consumer rules stayed enabled, as did SDK-specific rules and
explicit advertising-ID public API protection.

The myTarget 5.51.2 SDK uses Media3. Its classes and adapter contained no legacy
ExoPlayer class references or class-name literals; the installed AppLovin 13.6.3
SDK likewise had none. Legacy ExoPlayer 2.17.1 remained transitively present
through adapters. Its own reflection rules, Media3's rules and all unrelated
myTarget rules were retained. This does not prove that later SDKs never need
ExoPlayer keeps.

The Vungle/Unity changes affected unshaded `com.google.protobuf` only. Unity's
`gatewayprotocol.v1` message keeps, WebView/JavaScript rules and all unrelated
SDK-specific rules were preserved. Shaded Protobuf copies in other SDKs were
untouched. The resolved runtime's upstream `proguard.pgcfg` and Firebase's
protolite consumer rules supplied the generated-field protection below.

## Reflection protections retained in the host

The earlier Room/WorkManager startup repair remained in place:

```proguard
-keep class * extends androidx.room.RoomDatabase {
    public <init>();
}
-keep class * extends androidx.work.InputMerger {
    public <init>();
}
```

AGP 9 strict full mode can retain a class while removing the public no-argument
constructor required by reflection. Verify the actual constructor in DEX; a
class name or mapping entry alone is insufficient. See the linked incident for
the evidence and dependency chain.

After removing blanket Google rules, the host explicitly retained the APIs SDKs
can load by name:

```proguard
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient { public *; }
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info { public *; }
```

For the audited Protobuf Lite runtime, preserve generated fields used by schema
reflection while allowing other code/class names to be optimized:

```proguard
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite {
    <fields>;
}
```

Do not replace this with no Protobuf protection, or apply it blindly to full
Protobuf or relocated/shaded runtimes. Verify mapped fields and serialization
against the actual packaged code, including Firebase users of the shared runtime.

## Gate the real packaged scores

Lunaris added `:app:verifyReleaseDexOptimization` in `android/app/build.gradle.kts`.
It reads `build/app/outputs/bundle/release/app-release.aab` as a ZIP and parses
`BUNDLE-METADATA/com.android.tools/r8.json`. A portable equivalent should:

- Require `options.isOptimizationsEnabled`, `isObfuscationEnabled` and
  `isShrinkingEnabled` to be true.
- Read `stats.noOptimizationPercentage`, `noObfuscationPercentage` and
  `noShrinkingPercentage`; require finite numeric values between 0 and 100.
- Calculate each score as `100 - no...Percentage` and fail if any raw score is
  below the applicable minimum (25% in this case). Round only for display.
- Fail on missing/invalid metadata. Never synthesize or rewrite R8 statistics.
- Attach to the actual bundle task so its failure makes the release command
  fail. Lunaris used `bundleRelease.finalizedBy(verifyReleaseDexOptimization)`;
  adapt task/artifact selection for flavors rather than checking a stale bundle.

In hosts that implement that task, this reads an already-built artifact:

```sh
cd android
./gradlew :app:verifyReleaseDexOptimization
```

It does not rebuild native code. Record the artifact hash, version and source
revision with the result. A pass on an old AAB says nothing about unbuilt edits.

## Rebuild and verify within the authorized scope

The explicit Lunaris validation command, from its Flutter app root, was:

```sh
shorebird release android --dry-run --flutter-version=3.44.1 -- --dart-define-from-file=env/release.json
```

Preserve the target app's supported Flutter version, signing and defines; this
historical pin is not a universal default. Follow the host's opt-in build rules
and the [Shorebird skill](../skills/shorebird/SKILL.md). Documentation is not
authorization to build, register releases or upload. A dry run does not register
a patchable Shorebird release. Native keep-rule changes need a native rebuild;
a Dart-only patch cannot repair or optimize installed DEX.

After an authorized rebuild, inspect merged rules and packaged scores. Resolve
obfuscated classes through the matching map, excluding removed-class markers.
Inspect required constructors and generated fields in DEX. Test cold starts and
Protobuf round trips against code from this exact artifact. If a local debug
certificate is used only to install a bundletool-generated test APK, record that
limit and compare its DEX/native code to the AAB. Do not uninstall the user's
Play-signed app merely because upload and Play signing certificates differ.

For production, keep and test the actual production Shorebird release AAB through
Play's internal track. Include readable onboarding/UI, fresh install, an upgrade
from the previous store release, sign-in, consent, ad loading/display across the
enabled setup, rewarded callbacks and background/notification work. Network
inclusion alone is not proof of live inventory or every adapter's runtime health.
Promote the tested artifact; rebuilding creates a new artifact to verify.

## Recorded verification and unresolved findings

Final-artifact inspection found constructors with code for 169 inspected manifest
components/initializers/registrars and three WorkManager classes. It checked 406
mapped fields across 147 generated Protobuf messages without renamed/removed
field violations. Offline Unity and Firestore messages decoded correctly and
re-encoded identical wire bytes using the optimized APK code. Seven DEX files
and the arm64 Dart library matched the AAB byte for byte.

Three cold starts passed on a temporary Android 14 / API 34 arm64 emulator, with
no matching fatal/reflection errors. Repeats on host and software graphics also
kept the process alive. The first screenshot showed welcome text and controls;
later screenshots on both graphics backends omitted text/button labels. The
cause was not established. This was **not full UI or long-running stability
sign-off**, and did not verify all ad networks. Physical Play-installed testing
remained pending.

The pinned Shorebird SDK also warned that `libapp.so.sym` / `.dbg` was absent;
the AAB had its R8 map but lacked those Dart native crash symbols. No matching
app `keepDebugSymbols` override existed to remove. Future Kotlin/plugin and Apple
Swift Package Manager advisories remained. These separate findings were not
fixed or hidden by raising DEX scores. No Shorebird release or Play upload was
performed. Passing the local gate does not prove that Play has cleared a warning
on an already-published artifact.

## Primary references to recheck when applying this case

- [Play DEX optimization metrics](https://developer.android.com/google/play/vitals/code-optimization)
- [Play thresholds](https://developer.android.com/google/play/vitals)
- [Filtering consumer rules](https://developer.android.com/blog/posts/configure-and-troubleshoot-r8-keep-rules)
- [Keep-rule filter API](https://developer.android.com/reference/tools/gradle-api/9.2/com/android/build/api/dsl/KeepRules)
- [Protobuf 3.25.6 field protection](https://github.com/protocolbuffers/protobuf/blob/v3.25.6/java/lite/proguard.pgcfg)
- [Firebase protolite field protection](https://github.com/firebase/firebase-android-sdk/blob/master/protolite-well-known-types/proguard-rules.pro)
- [ExoPlayer 2.17.1 reflection rules](https://github.com/google/ExoPlayer/blob/r2.17.1/library/core/proguard-rules.txt)
