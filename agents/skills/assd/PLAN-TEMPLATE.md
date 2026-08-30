# PLAN.md structure

Sections in this order. Drop a section only when it genuinely does not apply,
and say so in one line rather than deleting it silently.

```markdown
# <Project name> — Plan

<One paragraph: what this is and who it is for.>

Plan date: <YYYY-MM-DD> (<note any later revision and what triggered it>)

---

## Brief

The Phase 1 brief, corrected: what it is, who uses it, the core flow,
non-goals.

## Verified findings

Facts checked against reality, each with the date it was verified. Tables work
well here: the external API's real behaviour, the sizes and rates involved, the
surprises. Follow each block with **the consequences for the design** as a
numbered list — this is the section that justifies the architecture.

## Architecture

The modules, the seams between them, and what crosses each seam. A diagram or a
schema where it earns its place. Name the adapter over every external
dependency.

## Decisions

Each decision: what was decided, why, and what was rejected. One subsection or
one table row each. This is the section future-you comes back to.

## Task plan

Milestones, then tasks in dependency order:

| Id | Task | Acceptance criterion | Depends on | Branch |
|----|------|----------------------|------------|--------|

Milestone 1 is the walking skeleton.

## Test plan

One subsection per level — unit, integration, contract, functional/e2e,
performance, resilience, security, data/migrations, accessibility, manual QA —
saying what is tested there, or one line on why the level does not apply.

Then the project-wide choices: framework, the single command that runs
everything, fixture strategy, what is mocked, and the CI gate that must be
green before a branch reaches `develop`.

Give performance its own table - what is measured, the budget, the load, the
command that measures it, and the latest number with its date - so a regression
is visible instead of argued about.

Finish with the map from task id to the tests that prove it.

## Security

The Phase 5 review, condensed: the threat model in one paragraph, then how
secrets are supplied and rotated, what personal data is held and for how long,
where the authentication and authorization checks live, the untrusted-input
boundaries and the validation applied at each, and the dependency-audit rule.
End with what is explicitly out of scope for v1.

## Risks accepted

What could sink this, how likely, and the response. Include the things you chose
not to solve in v1.

## Stack

Language, runtime, key libraries, and one line on why each is there.

## Installation and use

How someone runs it, once it exists.

## Before writing code

The short checklist of things that must be true before Phase 7 task 1 starts.
```
