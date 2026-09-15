---
name: ide-optimization
description: "Reduce irrelevant IDE indexing without hiding active source problems."
---

# IDE indexing and analysis scope

First identify which files cause the problem and whether they are active code.

- Exclude generated output, archived code, or incomplete templates only when
  they are not part of the app's active dependencies.
- Keep app source and selected starter kit modules included in analysis.
  Do not exclude the entire `packages` directory to make errors disappear.
- Merge narrow patterns into `analysis_options.yaml`; preserve existing rules.
- IDE indexing, analyzer exclusions, and Git ignore rules do different jobs.
  Hiding a folder in an editor is not a reason to stop tracking useful templates.
- Keep the user's actual SDK configuration. Do not copy another machine's path.

Story Saver excludes `packages/genrevibes_starter_kit/deprecated_old_version_1/**`
because it is archived code. That does not exclude the current modules.
Check that every added exclusion is narrower than the active code it sits beside.

## Diagnose the source before adding an exclusion

Identify whether the reported issue comes from editor indexing, Dart analysis,
Git repository discovery, or an active dependency error. These need different
changes. Excluding a folder from search does not fix its source, and excluding
an imported package from analysis can hide a real integration failure.

Inspect the current analysis options and IDE files. Add only the narrow generated
or archived path involved, preserving existing lint rules and SDK settings.
For a shared repo, avoid committing machine-specific absolute SDK paths or
editor workspace state that another developer cannot use.

After changing scope, confirm active app files and selected kit modules remain
included. The runnable examples supplied with these skills are intended to be
checked, not hidden merely because they are under `agents`. Explain exactly
which path was excluded and why it is not active source.
