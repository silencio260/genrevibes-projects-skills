---
name: quota-rate-limiting
description: "Implement app-owned usage limits with authoritative backend enforcement."
---

# Usage limits

The app/backend owns quotas. The kit does not provide a universal usage database
or automatic subscriber bypass.

1. Define the operation, allowance, period, timezone, and paid-tier behavior.
2. Enforce paid backend usage on the server using verified identity and access.
   Client counters can display remaining usage but cannot authorize spending.
3. Reserve/check and consume usage atomically. Use an operation ID so retry does
   not charge twice. Define whether failed operations refund reserved usage.
4. Handle concurrent requests, resets, offline state, and account changes.
5. Show quota exhaustion separately from network/auth/server errors. Do not
   open a paywall for every failure.

Connect [feature access](../content-locking/SKILL.md) only where the product uses
subscriptions or rewarded access. Remote config may tune client presentation;
it does not replace server enforcement. Check boundary/reset and retry behavior.

## Define how one operation consumes allowance

Write an operation contract before implementing the counter: authenticated owner,
operation ID, cost, allowance period, reset timezone, reservation lifetime, and
which failures release a reservation. Include the paid-tier policy explicitly;
subscription status does not automatically mean unlimited use.

The server checks access and reserves capacity atomically, then records the
operation against its ID. A retry with the same ID returns/continues that operation
instead of charging again. Decide how abandoned work and provider failure are
reconciled. Avoid a separate “read remaining” followed by an unprotected increment,
which allows concurrent requests to exceed the limit.

The client displays the server's remaining allowance and reset information. It
can disable a button for convenience, but the server still enforces the rule.
Show exhausted allowance separately from expired authentication, unavailable
network, or provider failure. Only offer a paywall when paid access actually
changes that limit.

Keep this logic in the app/backend's owning feature. Reuse kit entitlement policy
for client presentation, and the app's verified backend purchase records for
server decisions. Never accept a developer premium simulation as server proof.
