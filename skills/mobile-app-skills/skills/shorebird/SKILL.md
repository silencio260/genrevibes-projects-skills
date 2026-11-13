---
name: shorebird
description: "Prepare Shorebird releases and patches for an explicitly selected app version."
---

# Shorebird releases and patches

Inspect `shorebird.yaml`, the installed CLI, target platform, release version,
and build environment. Shorebird is optional; do not add it during kit adoption.

Maintain the app's exact release/patch recipes in its `README.md` and
`docs/commands.md`, below the Flutter run/build commands. Follow
[command documentation](../command-documentation/SKILL.md) when changing a recipe.
Both files must also carry the device-install recipes described in
[Install a release on a device](#install-a-release-on-a-device); an app whose
command guide documents how to release but not how to put that release on a
phone is incomplete.

- Match the baseline release's flavor, defines, signing, and toolchain inputs.
- Pin a new release's `--flutter-version` to the project's supported/tested
  Flutter version. Shorebird's default can differ from local Flutter and reject
  a previously working Gradle wrapper. See the
  [recorded version-mismatch fix](../../references/android-debug-build-performance.md#match-shorebirds-flutter-version-to-the-project)
  before preparing an Android release command.
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

## Install a release on a device

Android installs APKs, never an AAB, so `adb install` cannot take a Shorebird
bundle. Document both routes in the app's `README.md` and `docs/commands.md`,
and say which one each is for:

- **`shorebird preview`** — for a release already uploaded to Shorebird. It
  downloads that release, converts it with the cached `bundletool` and installs
  it, so it needs no local artifact. Confirm the flags against
  `shorebird preview --help`; at the time of writing it takes `--platform`,
  `--release-version`, `--device-id` and the `--ks*` signing flags, and prompts
  for a release when `--release-version` is omitted.
- **`bundletool` directly** — for the exact AAB on disk, which is the right
  choice when that specific bundle is what is under test, or when the release
  was never uploaded. Shorebird ships the jar at
  `$HOME/.shorebird/bin/cache/artifacts/bundletool/bundletool.jar`, so a separate
  `bundletool` install is not required and `which bundletool` is not a useful
  check for whether the route is available.

Both routes sign the generated APKs. Without the signing flags `bundletool`
falls back to a debug key, which will not match an installed store build. Treat
keystore passwords as the app's own prerequisite: reference private, temporary
password files in the documented template and never place a password in a
command argument or in documentation.

Neither command publishes, patches or uploads. Both still install software onto
a real device, so they fall under the repository's execution rules rather than
under documentation work.

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
