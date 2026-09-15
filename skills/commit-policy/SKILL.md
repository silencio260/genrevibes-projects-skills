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
