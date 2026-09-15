---
name: git-submodules
description: "Inspect and update pinned agents and starter kit submodules without losing local changes."
---

# Submodules

The parent repository records a commit for each submodule. Each nested
repository owns its files and history. Inspect before changing setup:

```bash
git status --short
git ls-files --stage
git config --file .gitmodules --get-regexp 'submodule\..*\.(path|url)'
git submodule status
```

In Story Saver, paths are `agents` and `packages/genrevibes_starter_kit`.
The historical section name `.agents` is allowed; its `path` must match `agents`.
For another app, use its actual paths and configured remotes.

- Check status inside each nested repository too. `ignore = dirty` can hide
  uncommitted files from parent status. Do not add `ignore = all` to conceal
  changed commit pointers.
- Fix a path mapping directly when that is the problem. Do not remove and re-add
  a working submodule or move its `.git` directory as a routine repair.
- For a clone with no local submodule edits, `git submodule update --init --recursive`
  checks out the recorded commits. This is not a fetch-and-upgrade-to-latest command.
- For an upgrade, choose a specific revision, inspect its changes, and preserve
  local edits. Do not run a blanket `--remote --merge` across the portfolio.
- Follow [commit policy](../../../commit-policy/SKILL.md). When authorized to
  publish, make nested commits available before recording their pointers in the
  parent. A parent commit cannot include uncommitted nested files.
- Verify a fresh recursive clone in a separate directory before claiming clone
  readiness. Verify the proposed/published revision, not just an older clean clone.

IDE repository discovery is separate from Git validity. Change IDE settings only
when needed; do not impose a developer's SDK path or hide errors with exclusions.

## Distinguish a file edit from a changed pinned commit

Use these read-only commands from the host root for this repository:

```bash
git -C agents status --short
git -C agents rev-parse HEAD
git -C packages/genrevibes_starter_kit status --short
git -C packages/genrevibes_starter_kit rev-parse HEAD
git diff --submodule=log -- agents packages/genrevibes_starter_kit
```

A nested repository can have uncommitted file changes while its HEAD still
matches the parent's recorded commit. Conversely, it can be clean but checked
out at a different commit. Report those two conditions separately. Parent
`git add agents` records the nested commit ID; it does not include dirty skill
files inside that repository.

For a requested upgrade, inspect the target commit and affected package/docs
changes first. If the nested repository is dirty, preserve that work and choose
an approach that does not overwrite it. Do not automatically stash or discard
the user's files as a setup step.

When publication is explicitly requested, publish the nested change to the
intended remote before publishing a parent pointer that depends on it. Then
verify that a fresh recursive checkout can resolve that exact pointer. A clean
local tree alone does not establish that another machine can fetch the commit.

For a path mismatch, compare `.gitmodules`, the tracked gitlink, and local Git
configuration. Repair the incorrect mapping with the smallest change. The
historical section name does not have to equal its current filesystem path.
