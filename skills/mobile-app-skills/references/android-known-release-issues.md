# Known Android release issues

Use these cases when a release build fails, or when the installed release's
logs match the recorded symptoms. Confirm the artifact and cause before
applying a historical fix. For lint delays or memory exhaustion, use the
[Android release skill](../skills/android-release-build-experiment/SKILL.md).

## AGP 9 removes Room's reflective constructor

### Recorded incident: Lunaris Network, 14 October 2026

The Play-installed Android release `1.0.0+2` on a Samsung SM-S918B repeatedly
crashed before Flutter started:

```text
java.lang.RuntimeException: Unable to get provider androidx.startup.InitializationProvider
Caused by: java.lang.RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase
```

The release used AGP 9.0.1 and R8 9.0.32. Dependency inspection established:

```text
com.appodeal.ads.sdk.adapters:unity_ads:4.17.0.0
  → com.unity3d.ads:unity-ads:4.17.0
  → androidx.work:work-runtime-ktx:2.7.0
  → androidx.work:work-runtime:2.7.0
  → androidx.room:room-runtime:2.2.5
```

Git history showed the Unity adapter enabled in the 11 October mediation
expansion. AGP 9.0.1 was already present in the initial project on 1 October;
this incident was not evidence of a new AGP upgrade in the release commit.

### Cause and evidence

Room 2.2.5's consumer rule was:

```proguard
-keep class * extends androidx.room.RoomDatabase
```

AGP 9 enables `android.r8.strictFullModeForKeepRules` by default. A class-only
keep rule no longer implicitly preserves its default constructor. Room needs
that constructor to instantiate its generated implementation through reflection.

The crash's R8 map ID matched the local release mapping exactly.
`build/app/outputs/mapping/release/usage.txt` listed the removed
`androidx.work.impl.WorkDatabase_Impl` public zero-argument constructor.
Inspection of both the original AAB DEX and the Play-installed APK DEX confirmed
that the class existed without a constructor. The defect existed before upload;
Play's APK generation was not its source. The overall first-DEX hashes differed,
so the artifacts were not claimed to be byte-for-byte identical.

The same release also removed the zero-argument constructors of WorkManager's
`ArrayCreatingInputMerger` and `OverwritingInputMerger`, which WorkManager loads
through reflection. Their removal was a related defect; the observed startup
stack trace specifically identified database creation.

All 138 manifest-declared components and startup initializers had constructors
retained in the matching release mapping. That check did not establish that
every component's internal initialization would succeed. The Google Mobile Ads
startup provider was absent, so a missing AdMob App ID was not this provider
crash. Do not infer that result for apps which do include the AdMob provider.

### Targeted source fix

In the host app's `android/app/proguard-rules.pro`, explicitly preserve database
implementation names and public no-argument constructors, and do the same for
WorkManager input mergers:

```proguard
-keep class * extends androidx.room.RoomDatabase {
    public <init>();
}

-keep class * extends androidx.work.InputMerger {
    public <init>();
}
```

Confirm that the app's release configuration includes this file. The Flutter
Gradle plugin used for this incident included it automatically; inspect the
actual release `configuration.txt` rather than assuming another toolchain does.
Keep unrelated optimization and mediation settings intact. Turning shrinking
off may hide the symptom but does not repair the incomplete reflection rules.

### Diagnose a matching failure

1. Read `adb -s <device> logcat -b crash -d -v threadtime` and confirm the process,
   installed version, installer, and exception chain. Preserve existing logs.
2. Match the crash's `r8-map-id-...` to the `pg_map_id` in `mapping.txt` before
   interpreting local shrinker output. A later build may have overwritten it.
3. Inspect `configuration.txt`, `usage.txt`, and the generated database's DEX
   methods. A kept class name is insufficient; verify its constructor too.
   Removed constructors elsewhere can be legitimate inlining or unused code;
   establish a reflective caller before treating removal as another defect.
4. From the Android directory, inspect dependency paths with
   `./gradlew :app:dependencyInsight --configuration releaseRuntimeClasspath --dependency androidx.work:work-runtime`
   and repeat for `androidx.room:room-runtime`. These are dependency diagnostics,
   not release builds, although Gradle may compile its own build logic.
5. If needed, inspect the installed base APK with Android SDK `apkanalyzer`:
   `apkanalyzer dex code --class androidx.work.impl.WorkDatabase_Impl <base.apk>`.
   Use `adb shell pm path <application-id>` to locate installed APKs; don't
   replace the user's installation just to read its code.

### Verify and describe the result accurately

At the time this case was recorded, the source rules were prepared and checked
against logs, the matching R8 reports, dependency paths, and shipped DEX. No
corrected release had been built, installed, or published. The phone became
offline during the expanded audit. Do not describe this historical source fix
as a verified device result or as proof that no later startup failure exists.

For an authorized rebuild, preserve the production defines, signing, and
toolchain inputs. Use a higher version code for a replacement store release.
For Shorebird apps, follow the [Shorebird skill](../skills/shorebird/SKILL.md)
and retain the artifact from that workflow. Native keep-rule changes require
regenerating native DEX; a Dart-only patch does not alter the installed DEX.

Inspect the new release output for the required constructors, then distribute
the exact intended AAB through Play's internal testing track. Install from Play
and check repeated cold starts, fresh installation, an upgrade from the previous
version, sign-in, rewarded ads, and background/notification behavior on relevant
Android versions. Use test installations when checking fresh-install behavior.
Promote the tested artifact; rebuilding after verification creates a different
artifact that needs verification again.

R8 shrinking happens during the release build. Play generates and signs
device-specific APKs from the uploaded bundle. Successful debug launches,
successful compilation, and store approval do not establish that the release
starts correctly. Review the pre-launch report for the exact version; reports
run subject to Google device-lab capacity and cannot identify every issue.
If a report shows successful launches for the affected version, investigate
that discrepancy rather than inventing how reviewers tested it.

### Primary references

- [AGP 9 constructor keep-rule behavior](https://developer.android.com/build/releases/agp-9-0-0-release-notes)
- [R8 full mode and reflective constructors](https://developer.android.com/topic/performance/app-optimization/full-mode)
- [Play internal testing](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Pre-launch report operation and availability](https://support.google.com/googleplay/android-developer/answer/9842757)
- [Pre-launch report limitations](https://support.google.com/googleplay/android-developer/answer/9844487)

## Meta adapters reference unpublished Facebook Infer annotations

### Recorded incident: Gravity Rolling Icon Launcher, 7 November 2026

A `shorebird release android` run failed in `:app:minifyReleaseWithR8`. R8
stopped on two missing classes:

```text
Missing class com.facebook.infer.annotation.Nullsafe$Mode (referenced from: com.facebook.ads.AbstractAdListener and 31 other contexts)
Missing class com.facebook.infer.annotation.Nullsafe
```

Lunaris Network had already hit the same failure and carries the two literal
`-dontwarn` lines for it, so this reproduces across apps rather than being one
project's dependency accident.

The same run also took 58m39s before failing. That duration was a separate
heap problem, not a symptom of this failure; see
[mediation build configuration](android-debug-build-performance.md). Do not
read a long R8 phase as evidence of a missing keep rule, or this failure as
evidence of a memory problem.

### Cause and evidence

Meta Audience Network is compiled against Facebook's Infer nullability
annotations. Infer is a static analyzer and Meta does not publish those
annotations as a runtime artifact, so the references cannot resolve during
shrinking. Two declared dependencies pull the Meta ad classes in:

```text
com.appodeal.ads.sdk.adapters:meta:6.21.0.0
io.bidmachine:ads.networks.meta_audience:6.21.0.1
```

`build/app/outputs/mapping/release/missing_rules.txt` listed exactly these two
rules and nothing else. R8 collects every missing class before it fails, so
that file is the complete blocker list for the run that produced it. Read it
before adding rules one failure at a time.

### Targeted source fix

In the host app's `android/app/proguard-rules.pro`:

```proguard
-dontwarn com.facebook.infer.annotation.**
```

The annotations are build-time only, so suppressing the reference is correct
here rather than hiding a class the app needs at runtime. This is not licence
to silence missing mediation classes in general: an absent active adapter
still needs its SDK at runtime, and `-dontwarn` on one would hide a real
packaging defect. Keep the suppression scoped to
`com.facebook.infer.annotation`; a broad `com.facebook.**` would also cover
the Meta SDK's own classes. The wildcard covers both reported classes and any
sibling annotation a later Meta adapter bump references.

### Which apps are affected

Any app declaring the Appodeal Meta adapter or the BidMachine Meta Audience
bridge. When this case was recorded, Smart Launcher had adopted both adapters
on 7 November 2026 without the rule and had not yet been built, so an app can
carry this defect without having seen it fail.

### Verify and describe the result accurately

At the time this case was recorded, the rule had been added to the host app's
ProGuard file and checked against `missing_rules.txt`, but no corrected
release had been built, installed or published. Do not describe it as a
verified release result. The next release build is the verification; keep
`build/` and the Gradle caches in place so that run is not also paying for a
cold rebuild.

### Primary references

- [Shrinking and obfuscating with R8](https://developer.android.com/build/shrink-code)
- [Meta Audience Network Android setup](https://developers.facebook.com/docs/audience-network/setting-up/platform-setup/android)
- [Facebook Infer](https://fbinfer.com/)
