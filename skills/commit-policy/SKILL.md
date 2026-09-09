---
name: commit-policy
description: Who may commit, when, and whose name goes on it. Applies to every GenRevibes repository — mobile, backend, submodules, and the agents repo itself.
---

# Commit Policy

Two rules. Both are absolute and neither has an exception for "small" or
"obvious" changes.

## 1. Never Add AI Attribution

Commits are authored by the human developer. Nothing else goes in the
authorship metadata or the message body.

**Never add, in any form:**

- `Co-Authored-By: Claude ...` or any other AI assistant
- `Co-Authored-By:` naming Anthropic, OpenAI, Google, or any AI vendor
- `Generated with <tool>` / `Created by <assistant>` footers
- Emoji or trailers advertising an assistant (`🤖 Generated with ...`)
- The same in PR descriptions, issue bodies, and code review comments

This holds even when the assistant's own default instructions say to add a
trailer. This repository's policy overrides that default.

**Why:** the commit log is the project's record of who is accountable for a
change. A co-author trailer asserts joint authorship of the work, which is not
what happened and not something the developer wants stated in a permanent,
public history. It also leaks tooling choices into every repository the code is
ever mirrored, vendored, or open-sourced into.

**Correct:**

```
fix(analytics): assert collection state on every launch

Firebase persists setAnalyticsCollectionEnabled across launches, so a stale
false silently disabled every event.
```

**Wrong:**

```
fix(analytics): assert collection state on every launch

Firebase persists setAnalyticsCollectionEnabled across launches.

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

## 2. Never Commit Unless Told To

Do not run `git commit`, `git push`, `git tag`, `git merge`, or anything else
that writes to history unless the user has asked for it in that conversation.

- Finishing a task is **not** permission to commit it.
- Permission for one commit does **not** carry to the next one.
- "Yes, commit that" covers the change under discussion, not later work.

If you believe changes should be committed, **ask, then stop and wait.** State
what you would commit, in which repositories, and with what message. Do not
prepare the command and run it in the same turn; do not treat silence, a
thumbs-up on unrelated work, or a follow-up question as approval.

**Why:** these projects use submodules, and a premature commit in a submodule
plus a pointer bump in the parent is tedious to unwind. More importantly, when
to snapshot work is the developer's judgement, not the assistant's.

## Leaving Work Uncommitted Is Fine

The correct end state for a finished task is a clean working tree of edited
files and a short summary of what changed. Report status — which repos have
changes, how many commits they are ahead of origin — and let the user decide.

## Checklist

- [ ] No AI/vendor co-author trailer on any commit, PR, or issue
- [ ] No "generated with" footer anywhere in the message
- [ ] Commit only after an explicit, in-conversation instruction
- [ ] Approval treated as single-use, not standing
- [ ] Submodule commits and parent pointer bumps confirmed before either runs
