# OPA and Cedar: Policy-as-Code Beyond Raw IAM JSON

## Why these come up separately from "Terraform = policy-as-code"

Everything built in this repo is technically already policy-as-code: Terraform, version-controlled in git, code-reviewed before merge. But both job descriptions name OPA and Cedar specifically, distinct from that. The difference is what Terraform validates versus what these tools validate: **Terraform checks that your HCL/JSON is syntactically well-formed and matches the provider schema — it has no idea whether the policy it's about to create is a good idea.** OPA and Cedar exist to check the policy's actual *logic and security properties*, before or independent of deployment.

## Open Policy Agent (OPA)

A general-purpose policy engine, not AWS-specific — the same tool that validates Kubernetes admission requests also validates Terraform plans. Policies are written in **Rego**, a declarative query language.

The relevant pattern for this job is **Conftest**: run OPA rules directly against a `terraform plan` JSON output, as a CI gate, *before* `terraform apply` ever runs. Example rules a policy team would write:

- "Reject any plan that creates an S3 bucket without a `security-tier` tag."
- "Reject any plan that attaches the literal `AdministratorAccess` policy ARN to a role" (exactly the pattern this repo's SCP #2 blocks at the AWS layer — OPA would catch the *attempt* at plan-time, before it even reaches AWS for the SCP to reject it).
- "Reject any SCP/RCP policy document containing `Action: "*"` with no scoping" (would have caught the RCP mistake made in lesson 5, at PR time, instead of at `terraform apply` time).

OPA doesn't replace SCPs/RCPs — it's a **shift-left** complement. SCPs/RCPs are the AWS-enforced, un-bypassable backstop; OPA/Conftest is the fast, pre-merge check that catches the same class of mistake earlier and cheaper.

## Cedar

AWS's own open-source policy language, designed to be simpler to read than IAM JSON and — the more important property — formally analyzable. Because Cedar's grammar is deliberately restricted (compared to the very expressive, very easy-to-misread IAM JSON policy language), tooling can *prove* things about a Cedar policy: whether it's a no-op, whether two policies contradict, whether a given request is definitely allowed or denied, without just testing it empirically.

Where Cedar is actually used today: **Amazon Verified Permissions**, a managed fine-grained authorization service for your own applications (think "should this user see this document" style checks), and internally at Amazon for large-scale authorization decisions. As of now, Cedar is **not** how you author SCPs, RCPs, or IAM policies themselves — those remain plain IAM JSON, exactly as this repo has been writing them. Be careful not to overclaim this in an interview: Cedar is relevant to the broader "policy-as-code" skill area both JDs mention, but it solves application-level authorization, not Organizations-level guardrails.

## The honest comparison

| | Raw Terraform/IAM JSON (this repo) | OPA/Conftest | Cedar |
|---|---|---|---|
| Validates syntax | Yes | Yes | Yes |
| Validates policy *logic/intent* | No | Yes, via custom Rego rules | Yes, via built-in formal analysis |
| Where it runs | `terraform apply` (AWS enforces) | CI, before `apply` | Inside an app (Verified Permissions), not Organizations |
| Used for SCP/RCP authoring today | Yes (this repo) | As a pre-merge gate on top of it | No |

## Likely interview questions

**Q: If Terraform already manages your SCPs as code, why would you also introduce OPA?**
A: Terraform validates that the HCL/JSON is well-formed; it doesn't know whether the policy you're about to create is a good idea. OPA/Conftest runs custom rules against the `terraform plan` output in CI, catching known-bad patterns (unscoped wildcards, forbidden managed-policy attachments) before the change ever reaches AWS — a faster, cheaper feedback loop than waiting for the SCP itself to reject a bad live request.

**Q: Would you use Cedar to author your organization's SCPs?**
A: No — Cedar isn't currently how Organizations policies are written; SCPs and RCPs are IAM JSON. Cedar's real fit is application-level fine-grained authorization (Amazon Verified Permissions), where its formal-analysis properties (proving a policy isn't a no-op, detecting contradictions) matter for a different kind of authorization decision than "can this account call this AWS API."

**Q: What's the actual failure mode OPA/Conftest is meant to catch that Terraform alone wouldn't?**
A: A perfectly valid, syntactically-correct policy that's still a bad idea — like the bare `Action: "*"` mistake this repo actually hit while writing RCPs. Terraform happily generated that JSON and submitted it; only AWS's own validation caught it, at apply time. A Conftest rule checking for unscoped `Action` values would have caught it in the PR, before `apply` ran at all.
