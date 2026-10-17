---
name: android-mediation-optimization
description: "Improve Android release DEX optimization with Appodeal and many enabled mediation adapters by auditing R8 consumer keep rules and verifying the resulting bundle."
---

# Android mediation release optimization

Use this for low Play Console DEX optimization, obfuscation or shrinking scores,
or excess retained SDK code in an Appodeal release with many enabled networks
and bridges. For R8 memory failures or slow debug builds, use the
[release build skill](../android-release-build-experiment/SKILL.md) or
[debug build guide](../../references/android-debug-build-performance.md).

Read the [Appodeal optimization case and procedure](../../references/android-appodeal-release-optimization.md)
before editing rules. It records the six exact dependency overrides, required
reflection protections, score gate, measured results and verification limits.

## Preserve the mediation setup

Keep the app's selected networks, adapters and mediation bridges enabled while
investigating rule restrictions. The successful Lunaris case improved scores
without removing networks, changing the memory budget, or upgrading dependencies.
Do not apply the historical adapter-trimming experiment as the default response
to low optimization scores. Preserve the owner's
[network preset](../../references/appodeal-network-defaults.md) and deliberate
app-specific choices.

## Audit before narrowing a rule

1. Record the artifact version/hash, resolved release dependencies, AGP/R8
   versions and actual packaged `BUNDLE-METADATA/com.android.tools/r8.json`.
   Read merged `configuration.txt`, `seeds.txt`, `usage.txt` and `mapping.txt`.
   Full shrinking can already be enabled while consumer rules restrict it.
2. Trace broad keeps to the exact originating AAR, including rules from MAX or
   other bridges. One remaining broad rule can still protect the same packages.
   Inspect direct references, reflection/string lookups, JNI where relevant,
   and the referenced library's own consumer rules before removing protection.
3. On a compatible AGP, replace only the audited artifact's consumer rules using
   `optimization.keepRules.ignoreFrom` with an exact group/artifact/version.
   Copy its full rule file into the host, record its source hash, and remove only
   justified blocks. Preserve every unrelated rule and required reflection API.
   Do not edit Gradle caches or globally disable consumer rules.
4. Keep Room/WorkManager constructors, advertising-ID reflection APIs and
   Protobuf Lite generated fields protected as applicable. The reference gives
   the concrete rules and their rationale. Do not generalize the recorded
   ExoPlayer or Protobuf decisions to uninspected SDK versions or shaded copies.
5. For each dependency upgrade, inspect the new AAR and redo the audit before
   updating its exact-version override. Unmatched versions should use their
   vendor rules again; do not widen the filter to make upgrades pass silently.

## Verify the artifact and report the limits

Follow repository build authorization rules. If the user has authorized a
specific build command, run it within that scope; documentation alone does not
authorize a build or an upload. For Shorebird, preserve its pinned Flutter,
production defines, signing and native release workflow; see
[Shorebird](../shorebird/SKILL.md).

Read scores from the newly built AAB, validate enabled R8 options and use a
packaged-score gate. Rebuilding is necessary after native rule changes; reading
an old AAB or issuing a Dart patch does not exercise the changes. Confirm merged
rules, required constructors and Protobuf fields in DEX, then check serialization
and repeated cold starts using that artifact. Preserve existing device data.

Before production, test the actual production Shorebird bundle through Play's
internal track, including readable UI, upgrades, sign-in, consent, supported ad
formats, rewarded callbacks and background work. Separate passing score checks
from runtime correctness and from Play Console processing. Preserve unresolved
findings in the report; the recorded Lunaris run had UI and symbol limitations.
