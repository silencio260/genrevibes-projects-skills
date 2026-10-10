# Faster Android debug builds after adding mediation

Use this when adding mediated ad SDKs makes ordinary `flutter run` slow. These
settings were used in Story Saver on an 8 GB M3 Mac with Gradle 8.13, Android
Gradle Plugin 8.11.1, Kotlin 2.2.20 and JDK 17. Adapt them to the target project;
the versions and heap sizes are a recorded working setup, not universal defaults.

## What the user runs showed

On 10 October 2026, the Gradle daemon log recorded these completed runs:

| Run | Existing build output | Gradle execution time |
|---|---|---|
| First, new daemon | Present | 56.5 seconds |
| Second, reused daemon | Present | 17.2 seconds |
| Third, reused daemon | Deleted by the user before this run | 245.5 seconds (4m05s) |
| Fourth, reused daemon | Present after the third run | 45.4 seconds |

No build failure or out-of-memory marker appeared in these four runs. The
combined changes below improved repeat builds; each change's contribution was
not measured separately. These durations cover Gradle daemon execution, not
the whole Flutter command, installation or debugger connection. The run after
deleting output rebuilt resources, DEX and native-library outputs even though
the daemon was still warm. A later `Lost connection to device` message is a
separate runtime/connection issue, not evidence that Gradle failed.

## Keep the daemon and disk caches reusable

Merge these values into `android/gradle.properties`; preserve other required
JVM options rather than creating duplicate property entries:

```properties
org.gradle.daemon=true
org.gradle.daemon.idletimeout=1800000
org.gradle.caching=true
org.gradle.workers.max=2
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G -XX:G1PeriodicGCInterval=60000 -XX:+G1PeriodicGCInvokesConcurrent
kotlin.daemon.jvmargs=-Xmx2G
```

- The daemon reuses a Java process and its memory caches between compatible
  builds. Keep the Gradle version, JDK and JVM options consistent; changing
  them can require another daemon.
- `1800000` is **30 minutes idle**, with the timer reset by subsequent builds.
  It is a local memory tradeoff, not a build timeout. The earlier 10-minute
  setting was observed shutting down the warm daemon during coding breaks.
  For longer breaks, a three-hour idle setting is `10800000`. Choose the idle
  period for the machine; do not promise an indefinite daemon lifetime.
- Stopping the daemon discards its memory caches but leaves downloaded
  dependencies, disk build caches and generated build output intact.
- The build cache reuses eligible task outputs; it does not make every task
  cacheable or prevent rebuilds after native dependencies change.
- Two workers bound concurrent Gradle work. In this project, a 2 GB Gradle
  heap previously failed during ad SDK DEX merging; keep the working 4 GB cap.
  The explicit 2 GB Kotlin cap avoids inheriting Gradle's larger cap. These
  are maximum heap sizes, not memory constantly allocated to each process.
- The JDK 17 G1 flags allow periodic concurrent collection after a minute
  without collection, which can reclaim unused heap between builds. They do
  not eliminate memory pressure or guarantee freedom from memory failures.
  Do not raise Gradle to 6 GB on this 8 GB machine as a routine speed fix.

Keep `build/`, the project Gradle working directory and the user's Gradle
caches between normal runs. Avoid routine `flutter clean` or deleting output
to make a repeat build faster. Deleting `build/` loses generated outputs even
when downloaded dependencies and some reusable task outputs remain cached.

## Declare build plugins once

Inspect both `android/settings.gradle` and `android/build.gradle`. Story Saver
already declared these in the `settings.gradle` plugins block:

```groovy
id "com.android.application" version "8.11.1" apply false
id "org.jetbrains.kotlin.android" version "2.2.20" apply false
```

The root `build.gradle` also declared the same Android and Kotlin plugins as
legacy `buildscript` classpath dependencies. Remove only those redundant
declarations when the settings-based declarations already supply the plugins.
Keep unrelated buildscript dependencies and any property still read by legacy
plugins; Story Saver retained `ext.kotlin_version = '2.2.20'`.

This removes redundant plugin dependency setup. It does not mean the app was
previously compiled twice, and Gradle may already have cached those artifacts.
Do not copy these version pins into another app or remove its only plugin
declaration. Preserve the versions supported by that app's Flutter/plugin setup.

## Route Appodeal packages to their repository

In the existing dependency repositories in `android/build.gradle`, exclude
Appodeal's Maven groups from Google Maven and Maven Central:

```groovy
allprojects {
    repositories {
        google {
            content {
                excludeGroupByRegex 'com\\.appodeal(\\..*)?'
            }
        }
        mavenCentral {
            content {
                excludeGroupByRegex 'com\\.appodeal(\\..*)?'
            }
        }
        maven { url "https://artifactory.appodeal.com/appodeal" }
    }
}
```

This skips repositories that do not host `com.appodeal` or its subgroups,
avoiding unnecessary lookups before Appodeal's repository. Other SDK groups
still resolve through the normal repositories. If the target app centralizes
dependency repositories in settings, apply the filters there instead. Preserve
its other repositories; do not replace the entire configuration with this example.

## Preserve the mediation integration

These debug speed changes did not remove active ad networks. Match adapters
and any required mediation bridge adapters to the installed SDK and dashboard
configuration; a dashboard toggle alone does not put its SDK into the APK.
Follow the [ads skill](../skills/ads/SKILL.md) when deciding which networks ship.
Comment genuinely unused adapters with a date and reason rather than deleting
them. Do not remove working demand sources simply to make a debug build faster.

Story Saver retained Jetifier: the inspection did not establish that all active
dependencies were safe without it. Do not disable it on an assumption. Also
do not enable Gradle configuration cache blindly: the inspected Flutter Gradle
tasks accessed `Project` during execution, and the local timing listeners were
not prepared for configuration cache. Neither configuration cache nor partial
R8 shrinking was part of this debug speed improvement. See the
[release build guide](../skills/android-release-build-experiment/SKILL.md) for
the separate release/R8 problem.

## Diagnose the next slow run without clearing caches

Read `~/.gradle/daemon/<version>/daemon-<pid>.out.log` for daemon reuse, start
and completion times, idle expiration and memory/build failures. Inspect output
timestamps and task outcomes to distinguish a new daemon from regenerated
native outputs. Keep process inspections to metadata such as PID, elapsed time,
CPU, RSS and executable name; full command arguments can expose Dart defines.

Story Saver also has `android/build-timings.gradle`, applied from the root
`android/build.gradle`, writing `build/reports/build-timing/latest.tsv` for debug
builds. This is a project helper, not a standard Gradle report available in every
app. It records root project evaluation to task-graph readiness, completed tasks
taking at least one second, and failed tasks. The latest repeat run recorded
11.9 seconds for that configuration interval and 8.4 seconds for Flutter's
compile task.

The report excludes earlier Gradle startup/settings/plugin resolution, Flutter
preparation outside Gradle, installation and debugger connection. Task times can
overlap; do not sum them as elapsed build time. It is overwritten on the next
debug build, so copy it before another run when comparing attempts. An interrupted
run may retain completed-task rows but not the duration of a still-running task.

Builds remain opt-in under `agents/AGENTS.md`. Saving this recipe does not
authorize a build. When a benchmark is requested, distinguish an ordinary repeat
run from a run after deleting output and report build time separately from
device installation/connection time. Do not guarantee a sub-three-minute cold
build from the repeat-run results above.

For live inventory in a debug run, use the
[live ads command and device selection guide](live-ads-debugging.md).

Sources for the mechanisms:
[Gradle daemon](https://docs.gradle.org/current/userguide/gradle_daemon.html),
[build cache](https://docs.gradle.org/current/userguide/build_cache.html),
[repository filters](https://docs.gradle.org/current/userguide/filtering_repository_content.html),
[JDK 17 G1 tuning](https://docs.oracle.com/en/java/javase/17/gctuning/garbage-first-garbage-collector-tuning.html).
