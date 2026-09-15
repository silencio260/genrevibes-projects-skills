---
name: chat-ai
description: "Implement app-owned AI chat, streaming, history, and backend integration."
---

# AI chat

Chat content and backend behavior belong to the app. Reuse kit auth, analytics,
purchases, and storage interfaces where needed; do not assume a kit chat module.

- Inspect the existing endpoint and message/session schema. Use the app's API
  layer and chosen backend; Firebase/Genkit is one option.
- Keep model credentials on the backend. Enforce session ownership and quota there.
- Define stream states: connecting, receiving, completed, cancelled, and failed.
  Preserve partial output when useful and cancel work when its owner closes.
- Keep request IDs stable across retries where supported to avoid duplicate work.
- Persist messages with explicit ordering and account/session ownership. Do not
  treat every authenticated user as authorized for every conversation.
- Keep typing state and retry controls accurate when a stream stops unexpectedly.
- Log counts and normalized outcomes rather than messages/prompts. Mask chat
  content if screen recording is enabled.

Add model selection, attachments, or history features only within the request.
Check cancellation, partial stream failure, duplicate send, and account switch.

## Map the feature to concrete layers

Keep conversation/message models and repository interfaces in the domain layer.
Use cases send, retry, cancel, and load history. The data layer talks to the actual
backend and maps its stream events. The BLoC owns the visible message list and
request state; widgets render messages and dispatch user actions.

Define a stable conversation ID, message/request ID, ordering field, role,
content, and completion status using the existing schema. Persist partial and
completed output deliberately. Do not append a new assistant message for every
stream chunk or confuse a disconnected stream with a completed answer.

On send, prevent duplicate submission of the same action. On retry, reuse the
operation ID only if the backend supports that contract. On cancellation, stop
the local subscription and request server cancellation if supported; closing a
Dart stream does not prove remote generation and billing stopped.

On account/session change, detach the old stream and prevent its late chunks
from entering the new conversation. The backend checks conversation ownership
and quota for every relevant operation. Keep model/provider secrets there.
Expose useful recovery for partial failure without sending prompts or message
bodies into unrelated logging and analytics systems.
