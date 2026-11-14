---
name: command-documentation
description: "Maintain an app's README and docs command guide when adding or changing run/build recipes, environment profiles, release workflows or developer tools."
---

# Document app commands

Every portfolio app owns a command guide in its root `README.md` and
`docs/commands.md`. Keep commands specific to that app; shared skills describe
the workflow and link to the app's actual recipes.

## Required order and coverage

Put **Flutter run commands first**, **Flutter build commands second**, then
release/patch workflows, setup, checks and other tools. Use this order near the
top of both files, before architecture and feature descriptions.

Document every build recipe the app uses in both files, including required
flags. The README must contain the commands themselves, not just a link.
The docs guide adds prerequisites, explanations and troubleshooting. Keep
maintained helper/tool commands below the run/build sections; detailed tool
options may remain in linked specialist docs.

When creating an app or changing a command, script, environment profile,
entrypoint, flavor, native build setting or toolchain pin that affects a recipe,
update the relevant commands in both files in the same change.

## Recipes every Android app must document

Besides run and build commands, each Android app's `README.md` and
`docs/commands.md` must contain, with app-specific values:

1. **Shorebird release and patch** recipes, when the app uses Shorebird
   ([shorebird](../shorebird/SKILL.md)).
2. **Install a release bundle on a device with `bundletool`**: the exact AAB on
   disk, converted with Shorebird's cached jar
   (`$HOME/.shorebird/bin/cache/artifacts/bundletool/bundletool.jar`), signed
   with the app's key through private password files.
3. **Install an uploaded release with `shorebird preview`**: for a release
   already on Shorebird, with `--release-version`, `--device-id` and the
   signing flags.
4. **Inspect release DEX optimization**: `python3 tool/check_dex_optimization.py
   <aab>` against the exact bundle that will be uploaded
   ([android-mediation-optimization](../android-mediation-optimization/SKILL.md)).

Copy the wording and templates from
[required recipes](references/required-recipes.md), and the checker script
from [tools/check_dex_optimization.py](references/tools/check_dex_optimization.py)
when the app lacks one. When auditing an app's command docs, a missing item
here is a gap to fill, not an optional extra.

## Derive recipes from the app

Inspect the app's existing README/docs, package scripts, tool entrypoints,
environment readers, IDE launch profiles, native build configuration and release
setup. Check installed CLI help when a flag or side effect is uncertain. Keep
working specialist guidance and link to it; do not replace it with generic commands.

For each recipe, give the working directory, purpose, prerequisites and exact
command. Include its actual mode, target/flavor, defines/configuration file,
toolchain pin and required flags. State the output path or service it starts,
and identify commands that upload, deploy, overwrite assets or use live data.
Distinguish an environment-file name from a Flutter build mode; a profile named
Release is not proof that it passes `--release`.

Use real app-owned file paths, with placeholders only for values the user must
supply, such as a current device ID or an explicitly selected patch baseline.
Mark those examples as templates. Do not publish credentials or invent missing
platform workflows. Keep config/signing prerequisites explicit without copying
their private contents into documentation.

## Check the documentation

Compare README and docs recipes for matching flags, paths, modes and toolchain
versions. Check referenced scripts, config examples, output paths and Markdown
links against source. Keep IDE/script recipes aligned or describe any existing
difference. Record whether a command was source-checked, help-checked or actually
executed; writing it down does not establish a successful build or deployment.

Follow the repository's existing execution rules. Documenting commands does not
authorize builds, app runs, tests, releases, patches or deployment.
