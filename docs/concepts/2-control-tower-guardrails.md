# Control Tower Default Guardrails & Overlap Analysis

## Why this matters for these roles

This repo deliberately skipped AWS Control Tower — every SCP, RCP, OU, and account was hand-built with raw Terraform so the underlying mechanics would be visible. That was the right choice for learning, but both job descriptions assume you're operating in a world where Control Tower (or a hybrid of Control Tower + legacy) already exists, and part of the job is knowing what it already does for you so you don't duplicate or conflict with it.

## What Control Tower actually is

Control Tower is a managed landing zone service. When you enable it, it:

- Creates a baseline OU structure automatically — a **Security** OU (with a dedicated log-archive account and an audit/security-tooling account) and a **Sandbox** OU. Notice this is exactly the kind of structure this repo built by hand (Security, Infrastructure, Workloads, Sandbox).
- Attaches its own **guardrails** — which are just SCPs (and AWS Config rules) that AWS packages, names, and manages on your behalf.
- Sets up centralized logging (CloudTrail + Config) into the log-archive account automatically.
- Provides **Account Factory** for provisioning new accounts through a standard template (see the AFT doc for the Terraform-integrated version of this).

## The two kinds of Control Tower guardrails

1. **Mandatory guardrails** — always enforced, can't be disabled. Example: preventing the log-archive account's CloudTrail/Config setup from being disabled. These exist as SCPs you didn't write and can't remove.
2. **Strongly recommended / elective guardrails** — optional, you turn them on per OU. These map to specific SCPs (e.g., "Disallow changes to a security-related resource," "Disallow deletion of a security-related instance") or Config rules that just detect (not prevent) violations.

The important detail: **mandatory and strongly-recommended guardrails consume real slots against the same per-target SCP quota that your custom SCPs use.** With the 2026 quota increase this is 10 SCPs per target instead of 5, but Control Tower's own guardrails still count against it — so "how many of my 10 slots does Control Tower already use at the OU I'm targeting" is a real, concrete planning question before you attach anything custom.

## What "overlap analysis" means in practice

Before authoring a new custom SCP, you check three things against Control Tower's existing guardrails at that OU/account:

1. **Redundancy** — does a Control Tower guardrail already do exactly this? (e.g., Control Tower already has region-restriction and CloudTrail-tamper-protection guardrails available — very close to SCP #7 and SCP #1 in this repo.) If so, enabling the built-in guardrail is usually preferable to a custom policy — less to maintain, and it's already tested by AWS at scale.
2. **Conflict** — could the two interact badly? This is rare for pure `Deny` policies (multiple denies just stack harmlessly, per the inheritance model), but becomes a real concern if either policy uses `Allow` to build an allow-list, since allow-lists must all agree, not just avoid contradicting.
3. **Quota consumption** — every enabled guardrail plus every custom SCP eats into the same 10-per-target ceiling. A landing zone with several strongly-recommended guardrails turned on, plus 8 custom SCPs like this repo has, could genuinely run out of room at a given OU — forcing exactly the kind of consolidation-by-theme this repo already practiced.

## How this repo's SCPs map to Control Tower equivalents

| This repo's SCP | Closest Control Tower guardrail concept |
|---|---|
| SCP #1 — logging tamper protection | Mandatory guardrails protecting the log-archive account's CloudTrail/Config |
| SCP #7 — region restriction | "Deny access to AWS based on requested Region" strongly-recommended guardrail |
| SCP #6 — deny root user | Not a stock Control Tower guardrail — genuinely custom |
| SCP #8 — data perimeter (identity) | Not a stock guardrail — this is the newer "data perimeter" pattern, layered on top |

That last row matters: Control Tower gives you a solid *baseline*, but data-perimeter-style guardrails (SCP #8, RCP #1, the VPC endpoint policy in lesson 7) are still something you author yourself on top of it — which is exactly what job 2's "data perimeter" line item is asking for.

## Likely interview questions

**Q: Your org uses Control Tower. Before writing a new SCP, what do you check first?**
A: Whether an existing mandatory or strongly-recommended Control Tower guardrail already covers this control, and how much of the per-target SCP quota is already consumed at the OU/account I'm targeting.

**Q: Can you remove or edit a Control Tower mandatory guardrail?**
A: No — mandatory guardrails are managed by Control Tower and reapplied if you try to detach them out-of-band; you'd need to work within Control Tower's own configuration (e.g., disabling that specific guardrail at the OU level through Control Tower itself, if it's not truly mandatory) rather than editing the underlying SCP directly.

**Q: If Control Tower already restricts regions, why would you still write a custom region-restriction SCP?**
A: You usually wouldn't duplicate it — you'd enable Control Tower's own guardrail for that OU instead. A custom SCP is for something Control Tower doesn't offer out of the box, or where you need a different regions list/exception set than the built-in guardrail provides.
