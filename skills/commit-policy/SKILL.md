---
name: commit-policy
description: "Apply the user's commit and publication scope in GenRevibes repositories and submodules."
---

# Commits and publication

- Do not commit, push, tag, merge, or rewrite history unless the user requested
  that action. Completing edits does not imply permission to commit them.
- Use existing authorization for the change under discussion. Do not ask again
  for a step already covered by it. Do not extend that scope to later unrelated work.
- Check each nested repository before staging. Stage only the intended files;
  preserve other edits and the configured author identity.
- Do not add AI co-author trailers or “generated with” footers to commits, PRs,
  issues, or review comments.
- For submodules, ensure nested commits are available to readers before
  publishing parent pointers. Follow the user's authorized repository scope.
- If publication has not been requested, leave edits uncommitted and summarize
  the changed repositories and relevant validation. Do not demand a commit as
  the last step of an otherwise complete task.

## Large media: screenshots, marketing and design files

App screenshots, Play Store art (screenshots, feature graphics, promo
mockups, zips of exports) and design sources (icon concepts, contact sheets)
are large binaries. Plain Git keeps every version forever, so each change makes
every clone bigger.

- Default: keep these folders out of Git with `.gitignore` entries, for example
  `/marketing/`, `/design/`, `/app_screenshots/`, `/app screenshots/`. Before
  adding an entry, check with `git ls-files <folder>` that nothing inside is
  already tracked.
- Option: when the user wants these files versioned, use Git LFS (Large File
  Storage). LFS commits a small pointer file and uploads the real file to
  GitHub's LFS store. A clone downloads only the versions it checks out.
  1. Check it is installed: `git lfs version` (install with `brew install git-lfs`).
  2. Run `git lfs install` once per machine.
  3. Track the folders, e.g. `git lfs track "marketing/**" "design/**"`. This
     writes the rules to `.gitattributes`.
  4. Remove the matching `.gitignore` entries, commit `.gitattributes`
     first, then add and commit the files.
- LFS only applies to files committed after tracking starts. Files already
  committed with plain Git stay in history unless history is rewritten. Do not
  rewrite history without the user's explicit request.
- GitHub Free includes 10 GB of LFS storage and 10 GB of download bandwidth
  per month, shared across all the account's repositories. Every fresh clone or
  CI checkout downloads the current LFS files and counts against bandwidth.
  Above the quota, usage is billed only if the account has a spending budget;
  otherwise pushes are blocked and clones get pointer files until the next
  month. Check the current numbers on GitHub's billing docs before relying on
  them.
- Files that are build inputs (launcher icons under `android/`, `ios/`,
  `assets/`) stay in plain Git. They are small and the build needs them in
  every checkout.
