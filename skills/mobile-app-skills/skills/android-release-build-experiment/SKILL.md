---
name: android-release-build-experiment
description: "Diagnose Android release build failures and reuse the recorded R8 partial shrinking experiment."
---

# Android release build failures

Use this when a release build fails or takes hours: `flutter build appbundle`,
`flutter build apk`, or a Shorebird release running the same Gradle tasks. It
records what failed in Story Saver during September 2026, what fixed each
failure, and what the fixes cost.

Read the failing Gradle task first. The same release build fails for unrelated
reasons at different steps, and each step needs a different fix. Builds stay
opt-in: state the exact command and let the user run it.

## Find the failing step before changing anything

Read the task name in `* What went wrong`. These three are common:

- `:app:lintVitalRelease` or long silence: release lint. It runs once per plugin
  module, so a Flutter app with many plugins can sit here for hours.
- `:app:minifyReleaseWithR8`: R8, which shrinks and converts the app's Java and
  Kotlin code. It fails either on missing classes or out of memory.
- `:app:packageReleaseBundle`: packaging, after R8 has already succeeded.

Evidence on disk, without rerunning anything:

- `build/app/outputs/mapping/release/`: a `mapping.txt` means R8 finished. Only
  `missing_rules.txt` means R8 stopped on missing classes.
- `build/app/intermediates/dex/release/minifyReleaseWithR8/`: timestamps show
  whether this run produced code.
- `~/.gradle/daemon/<gradle version>/daemon-<pid>.out.log`: the Gradle log.
- `~/Library/Application Support/shorebird/logs/`: Shorebird's own log, which
  says whether the release was created and uploaded after the build.

While a build runs:

- `ps -Ao pid,etime,%cpu,rss,command | grep GradleDaemon` for age and CPU.
- `jstat -gcutil <pid>`: column `O` near 100 with a climbing `FGC` count means
  the heap is exhausted and the build is spending its time on memory cleanup
  rather than progress. Hundreds of full cleanups is a stuck build.
- `jcmd <pid> Thread.print | grep -c com.android.tools.r8` confirms R8 is the
  step currently running.

Measure R8's input rather than guessing which dependency is heavy. Resolve the
release classpath with `<app>/android/gradlew -p android :app:dependencies
--configuration releaseRuntimeClasspath`, which compiles nothing, then count the
`.class` entries of each cached artifact under
`~/.gradle/caches/modules-2/files-2.1`. R8's memory tracks the number of classes
more closely than megabytes.

## Failures and their fixes

**R8 stops on missing classes.** R8 refuses to run while a library references
classes that are not in the app. AGP writes the exact rules to
`build/app/outputs/mapping/release/missing_rules.txt`. Copy those `-dontwarn`
lines into `android/app/proguard-rules.pro`. Keep this fix; it is not a
workaround.

**Release lint takes hours.** Add to the `android` block of
`android/app/build.gradle`:

```groovy
lint {
    checkReleaseBuilds false
}
```

Lint then runs from Android Studio when wanted, instead of on every release
build. Keep this fix. It also frees the memory lint was holding.

**R8 runs out of memory** (`ERROR: R8: java.lang.OutOfMemoryError: Java heap
space`). R8 examines the whole app at once, so its memory grows with total code.
Options, cheapest first:

1. Raise the Gradle heap in `android/gradle.properties`
   (`org.gradle.jvmargs=-Xmx6G -XX:MaxMetaspaceSize=1G`). This is the usual fix
   and needs a machine with the memory to spare.
2. Give R8 its own process and heap through AGP execution profiles in
   `settings.gradle`: see
   [Configure how R8 runs](https://developer.android.com/build/r8-execution-profiles).
3. Remove dependencies. In a mediated-ads app, each ad network adapter brings a
   full SDK, and dropping unused networks removes real work.
4. Partial shrinking, recorded below. No extra memory, but experimental.
5. Build on a machine with more memory.

Keep rules do not help here. A package-wide `-keep` still makes R8 read and
trace that code; Google's guidance on
[adopting optimizations incrementally](https://developer.android.com/topic/performance/app-optimization/adopt-optimizations-incrementally)
says such rules mean paying R8's build cost with none of the benefit.

**Packaging cannot find `r8-metadata.dat`.** Only happens with partial
shrinking; see the experiment.

## The partial-shrinking experiment: Story Saver, 16 September 2026

It worked, and a day later it was no longer needed: trimming unused ad
adapters let full shrinking fit in the same memory. Read this section for
what partial shrinking does and costs, then the next section for the fix
that replaced it. Reach for partial shrinking only when the dependency list
is already minimal.

Setting: 8 GB M3 MacBook, Gradle heap 4 GB, AGP 8.11.1, Gradle 8.13, JDK 17,
Flutter via Shorebird. Appodeal mediation with 26 network adapters. The release
classpath held about 109,000 classes; 65% were reachable only through Appodeal
and its adapters, 15% were the rest of the app, including Flutter, Firebase,
OneSignal, RevenueCat and PostHog. The previous successful release, in January
2026, had AdMob alone and built with the same 4 GB heap. The owner ruled out
raising memory, cloud builds, dropping ad networks, and turning R8 off.

Changes, and what each one did:

1. `android.experimental.gradual.r8=true` in `android/gradle.properties`. **This
   is what fixed the memory failure.** R8 stops fully optimizing every package,
   so it needs far less memory. R8 had been dying about five minutes in; with
   this it finished in about ten minutes inside the same 4 GB.
2. `android.r8.optimizedShrinking=true`, required by the first. Without it R8
   refuses: "Partial shrinking only supports optimized resource shrinking". The
   name is version-specific: AGP 8.11.1 calls it `android.r8.optimizedShrinking`,
   and AGP 8.12 renamed it to `android.r8.optimizedResourceShrinking`, which is
   the name Google documents. AGP 9 makes it the default.
3. A placeholder metadata file. In partial mode R8 never writes
   `build/app/intermediates/r8_metadata/release/minifyReleaseWithR8/r8-metadata.dat`,
   and `packageReleaseBundle` refuses to start because an input file it is told
   to read does not exist. AGP locks that property, so the build file cannot
   clear it. A `doLast` on `minifyReleaseWithR8` that writes `{}` there when R8
   left nothing lets packaging run. Write an empty object rather than invented
   optimization data: the file ships as `BUNDLE-METADATA/com.android.tools/r8.json`
   and Play reads it as a report on the build.
4. The `-dontwarn` lines, which cleared an earlier R8 refusal.
5. Skipping release lint, which turned hours into minutes.

Result: the bundle built (`app-release.aab`, 116 MB) and Shorebird created and
uploaded the release.

Costs to weigh before repeating this:

- **Size.** Most SDK code ships unshrunk: 102 MB of code uncompressed, against
  roughly 15 MB in a fully shrunk build, about 55-70 MB for a phone to download.
  Play allows 500 MB for a base module, so size is a product problem, not a
  blocker.
- **Experimental switches.** `android.experimental.gradual.r8` is undocumented,
  and both switches can change or disappear in an AGP upgrade. AGP 8.13 lists
  fixes for partial shrinking, so an upgrade is the better route when the app
  can take one.
- **The placeholder.** Play's optimization report for that build is an empty
  object.
- **Verify on a device.** Less optimization and resource removal can change
  runtime behavior: check ads including full-screen, paywall and restore,
  notifications and their icon, images across the app, and that every module
  reports ready in the app's module health screen. Prefer an internal testing
  track for the first upload.

To undo the experiment, remove both switches from `android/gradle.properties`
and the placeholder block from `android/app/build.gradle`. The `-dontwarn` lines
and the lint setting are worth keeping either way.

## What finally worked: cut the dependencies, 17 September 2026

The Appodeal dashboard (Mediation Setup > Ad Networks) listed accounts for 13
networks, while the app shipped 26 adapters. Commenting out the 11 with no
account, keeping `bidmachine` and `bidon` because Appodeal ships them itself,
removed 16,175 of 108,903 classes, about 15%.

That was enough. With the partial-shrinking switches and the placeholder removed,
R8 completed a full shrink inside the same 4 GB heap it had been dying in, in
about 10 minutes. Nothing experimental ships.

| | 26 adapters, partial shrinking | 15 adapters, full shrinking |
|---|---|---|
| R8 in a 4 GB heap | only with partial shrinking | completes |
| Compiled code | 102 MB | 64 MB |
| AAB file | 116.5 MB | 104.5 MB |
| Phone download (arm64) | about 57 MB | 42.8 MB |

Comment those dependencies out; do not delete them. Each commented line carries
the date and the reason it is off, so restoring a network is one uncommented
line with its original version pin, and a reviewer sees a decision rather than a
gap. Treat every vendor SDK the same way, and comment out experimental build
flags rather than deleting them so the next person can reproduce the experiment.

The lesson for the next app: **measure and cut the dependency list before
reaching for build flags.** A mediation SDK's default adapter list is the single
biggest input to both R8's memory and the download size. See the
[ads skill](../ads/SKILL.md) for how to decide which adapters ship.

Two fixes from that day are worth keeping in any app that shrinks resources:

- **Protect resources named only from Dart.** `android/app/src/main/res/raw/keep.xml`
  with `tools:keep="@drawable/*,@mipmap/launcher_icon"`. Resource shrinking cannot
  see Dart strings, so a notification icon named as text can be deleted and
  notifications then silently stop appearing.
- **Bump the build number for each Shorebird release.** Shorebird refuses a second
  release for a version it already has: "It looks like you have an existing android
  release for version X. Please bump your version number and try again." Deeper
  than the error: never upload an AAB whose version matches a Shorebird release
  built from different code, or later patches target the wrong baseline.

## Verify a release bundle without a device

Useful when someone ships without a device test, and as a sanity check after any
shrinking change. All of it reads the AAB and mapping file; none of it needs a
phone.

- **Was it really a full shrink?** `build/app/intermediates/r8_metadata/release/minifyReleaseWithR8/r8-metadata.dat`
  written by R8 is a couple of kilobytes. A 2-byte file is the partial-shrinking
  placeholder; an empty folder means R8 wrote nothing.
- **What a phone downloads.** `unzip -v <aab>` and total the compressed sizes of
  `base/dex/`, `base/lib/<one abi>/`, `base/assets/` and `base/res/`. Ignore
  `BUNDLE-METADATA/`; Play strips it.
- **Resources survived.** `unzip -l <aab> | grep <icon name>` for every resource
  the Dart code names as text.
- **Platform wiring survived.** `unzip -p <aab> base/manifest/AndroidManifest.xml | strings`
  and grep for the receivers and services a feature needs.
- **SDKs survived R8.** Grep `build/app/outputs/mapping/release/mapping.txt` for
  entry classes such as `com.revenuecat.purchases.Purchases`,
  `com.onesignal.OneSignal`, `com.appodeal.ads.Appodeal` and the app's own
  `MainActivity`. A class in the mapping shipped. Do not judge by searching the
  compiled code for package names: R8 renames anything without a keep rule, so a
  missing name string means renamed, not removed.

## Routes that do not help

- A plain `flutter build appbundle` instead of Shorebird fails identically:
  Shorebird runs the same Gradle tasks, and the heap, AGP and R8 versions come
  from the project. Rebuilding a Shorebird release with plain Flutter also
  forfeits patching.
- Stopping the Kotlin compiler daemon before R8 frees system memory but not the
  Gradle heap, which is what the error is about.
- `-dontoptimize` and package-wide keep rules make output worse without
  relieving R8's memory.
