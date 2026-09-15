---
name: error-handling
description: "Translate kit and provider failures into useful app states without hiding errors."
---

# Error handling

The kit uses `KitResult<T>`, `KitSuccess<T>`, `KitFailure<T>`, and `KitError`.
Keep these inside kit integrations. If the app uses `Either` or another result
model, translate once at its repository boundary rather than rewriting the kit.

- Handle provider failures, thrown exceptions, and timeouts at the operation
  boundary. Preserve the original cause/stack for diagnostics.
- Keep cancellation, pending work, permission denial, unconfigured services,
  and unexpected failure distinct. Do not turn all failures into empty success.
- Show a useful next action in UI and release busy state in every completion path.
- A timeout does not prove cancellation. Avoid automatic retries for purchases,
  submissions, and other operations that may already have reached the server.
- Treat connectivity checks as hints, not proof a request can or cannot succeed.
- Send unexpected failures through the existing crash path once. Do not log
  tokens, passwords, form text, or private payloads.

Check both returned failures and thrown exceptions. Preserve an existing app's
error model unless changing it is part of the request.

## Follow one failure from storage to the screen

The [complete feature example](../../references/feature-walkthrough.md) contains
a repository that translates a `KitResult` into the app's `Either<Failure, T>`.
Its BLoC handles both branches and preserves the displayed value if saving fails.
Use that structure for this app and new portfolio features; keep an existing
app's established result model when adopting the kit there.

A missing preference can legitimately select a default. A failed read cannot
be treated as the same event without a deliberate product recovery rule. The
example therefore returns false for a missing bool and a failure for an
unsuccessful store operation.

At each boundary, decide what belongs there:

| Boundary | Responsibility |
|---|---|
| Provider/adapter | Normalize vendor outcomes and preserve diagnostic cause. |
| App repository | Translate into the app's failure types and domain data. |
| Use case | Apply the operation's business rule. |
| BLoC/controller | End busy state and expose a useful result or retry action. |
| Widget | Render safe user-facing text; avoid raw exception strings. |

Guard late completions after disposal/account change. In an event handler, check
its supported completion/ownership mechanism before emitting after awaited work.
For side effects with uncertain delivery, make retry a deliberate action using
any server-supported deduplication, rather than a catch block that retries forever.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_core](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/lib/genrevibes_core.dart).
