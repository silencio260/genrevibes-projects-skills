---
name: firebase-functions-v2-auth
description: "Diagnose 401 and 403 responses from Firebase Gen 2 HTTP functions before changing access settings."
---

# Gen 2 HTTP authentication

First determine which layer rejected the request. A 401 or 403 alone does not
prove that Cloud Run IAM blocked it.

1. Inspect the function type, deployed target, response, and request logs.
   Determine whether the request reached the handler.
2. Distinguish Cloud Run invocation identity from Firebase user authentication.
   Inspect the actual invoker/IAM policy; do not assume every deployment has the
   same default.
3. If an HTTP endpoint is intentionally reachable by mobile clients using
   Firebase ID tokens, it may need public invocation at the infrastructure layer.
   That does not remove authentication or authorization inside the handler.
4. Before changing that setting, verify the handler checks the Firebase ID token
   before protected work, rejects invalid/missing tokens, and checks ownership
   and access for the requested resource. A placeholder callback is not proof.
5. Keep service-to-service endpoints restricted when they use IAM identity.
   Do not apply `invoker: "public"` to every function or confuse callable and
   raw HTTP protocols. CORS is not authentication.
6. Prepare the exact configuration/code change for the diagnosed endpoint.
   Deploy or change live IAM only when authorized. Never log bearer tokens.

Reference: [invoker options](https://firebase.google.com/docs/reference/functions/2nd-gen/node/firebase-functions.https.httpsoptions).
For handler verification, follow [Firebase ID tokens](https://firebase.google.com/docs/auth/admin/verify-id-tokens).
Check current docs and the installed SDK before using a configuration example.

Report whether the failure was infrastructure rejection, token verification,
resource authorization, or still undiagnosed.

## Trace one rejected request

Record the intended endpoint, environment, request protocol, response status,
and a safe request/correlation ID. Inspect logs without copying authorization
headers or token contents. Determine whether an entry from this request appears
inside the handler before changing access policy.

| Evidence | Next investigation |
|---|---|
| Infrastructure rejects before handler | Check the actual service's invoker policy and the caller identity/token audience. |
| Handler rejects token | Check the expected Firebase project and verification path; do not make the handler public as a fix. |
| Valid identity but resource denied | Check ownership/role rules for that resource and operation. |
| Browser preflight fails | Inspect CORS separately while preserving authentication on the real request. |
| No clear evidence | Gather logs/target details; do not guess that every 403 needs public invocation. |

For a proposed infrastructure-public mobile endpoint, read the real handler from
entry to protected work. Confirm verification precedes the operation, the decoded
identity is used for authorization, and invalid input does not select another
user's records. Merely importing the Admin SDK does not establish those checks.

Keep any IAM change scoped to that diagnosed endpoint. A service-to-service
function may have a different caller model from a mobile-client endpoint in the
same project. After an authorized change, distinguish confirmed handler entry
from confirmed successful authentication and resource authorization.
