---
name: kit-upgrade
description: "Upgrade a pinned starter kit revision and migrate the affected app integrations."
---

# Upgrade the kit

1. Read the app's pinned kit commit and local changes. Read the target revision's
   changelog, package manifests, and public APIs before changing the pointer.
2. List the packages the app uses and the changes that affect them. An unused
   adapter's change does not require adding that adapter.
3. Apply the chosen revision without discarding local edits. See
   [submodules](../../skills/git-submodules/SKILL.md).
4. Update dependency paths, constraints, constructors, and callbacks that changed.
   Keep app-specific policy choices explicit when kit defaults changed.
5. Preserve stored keys and values with [storage migration](../../skills/storage-migration/SKILL.md).
6. Check initialization, optional failures, cleanup, and retry. Check changed
   native configuration and report any required build/device checks.
7. Record the kit commit, affected packages, migrations, and actual validation.

A local commit does not prove that another machine can fetch it. Before a
release, verify the pinned commits are available to a fresh recursive clone.
Commit and push only within the user's explicit authorization.

## Files to compare for an upgrade

Compare the current and target versions of each adopted package's pubspec,
public exports, constructor parameters, result models, and changelog. Also inspect
Android/iOS files for adapters whose native plugin changed. A patch-level package
version does not prove there was no native change.

For the parent app, record both the old pinned kit commit and the proposed commit.
A submodule's branch setting controls update behavior; the recorded commit is
what a fresh clone checks out. Read status inside the kit before checkout so
uncommitted work is not overwritten.

### Example: replay defaults changed

An older app intentionally records a configured share of users. The current kit
starts at 0% with masking enabled, while the
[session replay convention](../../skills/session-replay/SKILL.md#masking-defaults-and-remote-controls)
for new integrations requires global text/images unmasked by default and controlled
through Remote Config. Pass explicit `replayDefaults` and align the app template
for new integrations. When upgrading an existing app, preserve its deliberate
policy unless changing it is requested. Inspect activated remote values too;
changing bundled defaults does not replace values already fetched. Confirm that
Lab uses the same schema as runtime.

### Completion evidence

Record the dependency resolution result, changed call sites, storage mappings,
and analyzer findings. Separately list native checks not performed. Before an
authorized release, confirm the nested commit can be fetched and the parent
points to it. Do not change unrelated provider versions during the upgrade.
