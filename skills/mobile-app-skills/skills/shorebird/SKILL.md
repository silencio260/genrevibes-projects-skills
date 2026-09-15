---
name: shorebird
description: "Prepare Shorebird releases and patches for an explicitly selected app version."
---

# Shorebird releases and patches

Inspect `shorebird.yaml`, the installed CLI, target platform, release version,
and build environment. Shorebird is optional; do not add it during kit adoption.

- Match the baseline release's flavor, defines, signing, and toolchain inputs.
- Choose an explicit release version when preparing a patch. Do not silently
  target `latest` when the intended user population is unknown.
- Inspect the diff for native code, plugin, asset, or engine changes and read
  the current [patch requirements](https://docs.shorebird.dev/code-push/patch/).
  Do not assume every dependency change is patchable or every change requires
  a full release; use the actual build inputs and tool diagnostics.
- Store submission must use the artifact produced by the Shorebird release
  workflow. Do not rebuild it with plain Flutter and assume patch support remains.
- Report rollout/apply behavior accurately; a patch is not guaranteed to reach
  every device immediately. See the [workflow](https://docs.shorebird.dev/code-push/guides/code-push-guide/).
- Prepare source changes and a concrete target before any requested publish step.
  Release and patch commands can upload artifacts; run them only within explicit
  authorization. Builds and previews follow repository validation rules.

Check the chosen release, defines, supported changes, and actual command results.
Do not add CI configuration as part of this skill.

## Prepare a patch against a concrete baseline

Record the intended app ID, platform, release version, flavor, compile-time
defines file, and baseline source revision. Compare the proposed source and
package/native changes with that baseline. Read the installed CLI help and
current official patch requirements before selecting the command.

Keep preparation separate from execution: source inspection can establish what
changed, but it cannot prove the patch builder accepts those changes or that
users received them. Commands that build/upload a release or patch require the
authorization described above and must target the established release.

If diagnostics show the change cannot be delivered as the intended patch,
explain the specific incompatible change and the required release path. Do not
remove a needed plugin/native change just to make a patch appear possible.
Preserve the exact artifact produced for a store release and record its version;
a separately rebuilt artifact is not automatically the same baseline.

In the handover, state whether work was only prepared, built, uploaded, or
observed on a device. Include the command outcome actually obtained without
claiming immediate portfolio-wide rollout.
