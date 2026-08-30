---
name: assd
description: Plan, organise, test and ship a project end to end - describe it, grill it, break it into tasks, design its test suite, review it for security, write PLAN.md, then drive it on GitHub with git flow.
disable-model-invocation: true
---

# assd

Take a project from a vague idea to a repository on GitHub whose `main` branch
holds tested, working code. Seven phases, in order. **Each phase ends with a gate:
state where you are, and wait for the user to confirm before moving on.** Never
skip a phase because the project "looks small".

Write `PLAN.md`, commit messages and issue titles in the language the user is
speaking. Code and code comments are always in English.

---

## Phase 1 - Describe the application

Get an initial description on the table so both of you are looking at the same
thing. Ask the user to describe what they want to build, then write it back as a
short brief:

- **What it is**: one paragraph, no jargon.
- **Who uses it** and what they get out of it.
- **The core flow**: the single path the app exists to serve, start to finish.
- **Explicit non-goals**: what this is *not*, so scope stops drifting later.
- **Unknowns**: everything you cannot answer yet. This list is the raw material
  for Phase 2, so be honest and generous with it.

Facts are your job, never the user's. If the brief depends on something you can
check - an API's real response, a feed's actual contents, whether a library
still exists, what the current repo already contains - go and check it before
asking. Verified facts belong in the brief, marked with the date they were
verified.

**Gate**: show the brief. Ask the user to correct it. Do not start Phase 2 on a
brief they have not seen.

---

## Phase 2 - Grill it

Call the Skill tool with `grilling`, seeding it with the brief and the unknowns
list from Phase 1.

Run it to exhaustion: rounds of numbered questions with your recommended answer,
recomputing the frontier after each round, until the frontier is empty. Do not
short-circuit it because the answers "seem obvious" - the recommended answer is
your job, the decision is the user's.

The grilling must settle, at minimum:

- Scope and the cut line for v1.
- Data model and where state lives.
- Stack, runtime, and the deployment/distribution target.
- External dependencies and what happens when each one fails.
- The failure modes that matter and how the app behaves in them.
- What "done" means, and how it is observed.

Keep a running record of every settled decision - you will paste it into
`PLAN.md` in Phase 6, with the *why*, not just the *what*.

**Gate**: the grilling skill's own rule applies - do not act on it until the user
confirms you have reached a shared understanding.

---

## Phase 3 - Organise the work into tasks

Turn the settled design into an ordered task list. A task is:

- **Vertical**: it delivers a thin slice a user or a test can exercise, not a
  layer. "Fetch and parse one feed into records" beats "write all the models".
- **Small**: a few hours of work. If you cannot describe its acceptance
  criterion in one sentence, split it.
- **Ordered by dependency**, and grouped into milestones. Milestone 1 must be a
  walking skeleton: the thinnest end-to-end path that runs.
- **Testable**: every task names the tests that prove it (Phase 4 fills in the
  detail).

For each task record: an id (`T1`, `T2`, ...), a title, what it changes, its
acceptance criterion, its dependencies, and its branch name
(`feature/<short-slug>`).

Call out the risky ones explicitly - the tasks whose estimate you distrust,
usually the ones touching something external.

**Gate**: show the task list and the milestone cut. Let the user reorder, drop
or split before you continue.

---

## Phase 4 - Design the test suite

Plan the tests *before* the code exists. Go through every level and either place
tests in it or write down why the level does not apply to this project - an
empty level is a decision, never an omission.

- **Unit**: pure logic, parsing, formatting, edge cases, boundaries, error
  paths. Fast, no I/O.
- **Integration**: real seams between modules, and the adapters over anything
  external, exercised against recorded fixtures.
- **Contract**: the shape you assume of every external API/feed/schema, plus a
  check that fails loudly when the real thing drifts from the fixture.
- **Functional / end-to-end**: the core flow of Phase 1, driven the way a user
  drives it (CLI invocation, HTTP request, UI interaction).
- **Performance**: what has to be fast, the budget in numbers, under what load,
  and measured with which command - a budget nobody measures is a wish. Pick the
  shape that matches the project:
  - **Web UI**: driven in a real browser, not by eyeballing it. First load and
    the core interaction of Phase 1, on a throttled network and CPU, capturing
    the numbers (load, largest paint, interaction latency, bundle size).
  - **Backend / API**: a load generator firing at a running instance - state the
    concurrency, the duration, and the p50/p95/p99 latency and error rate you
    expect. Find the point where it degrades rather than only proving the happy
    number.
  - **CLI, batch or library**: timed over a representative input whose size you
    state, repeated enough times to be stable.
  Include the resource limits that matter (memory, cost, API quota, rate
  limits), and record a baseline so a later run has something to be compared
  against.
- **Resilience**: dependency down, timeout, malformed payload, empty input,
  partial failure, retry and backoff behaviour.
- **Security**: input validation, secret handling, authn/authz, injection
  surfaces, dependency audit.
- **Data / migrations**: idempotency, deduplication, restart from a dirty state.
- **Accessibility and cross-platform**: only where there is a UI or more than one
  target.
- **Manual QA**: the checks a human must still run, written as a checklist.

Also decide, once, for the whole project:

- Test framework, runner, and the single command that runs everything.
- Fixture strategy: what is recorded, where it lives, how it is refreshed.
- What is mocked and what is real. Prefer real over mocked at the seams.
- Coverage expectations, stated as which behaviours must be covered - not as a
  percentage target.
- The CI gate: exactly what must be green before a branch reaches `develop`.
- Where the performance numbers are recorded, and whether the budget is enforced
  automatically or measured by hand at the end of each milestone.

Map every test back to the task from Phase 3 that introduces it.

**Gate**: show the test plan. Confirm the run command and the CI gate with the
user.

---

## Phase 5 - Security review

Review the design for the things that get a project breached, while changing the
answer is still free. This is a design review, not a scan: there is no code to
scan yet.

Go through every heading below and either write down the answer or write down
why the heading does not apply - "no user accounts in v1" is an answer, silence
is not.

- **Secrets and credentials**: every API key, token, password, private key and
  connection string the app needs. For each: where it comes from (environment,
  secret manager, keyring - never the repository), who can read it, how it is
  rotated, and what happens if it leaks. Confirm `.gitignore` covers every file
  that could hold one (`.env`, credential files, dumps), and that no secret can
  reach logs, error messages, telemetry, a client-side bundle or a URL.
- **Personal and sensitive data**: what personal data the app touches, why each
  field is needed, where it is stored, how long it is kept, and who it is shared
  with. Cut every field you cannot justify - data you never collect cannot leak.
  State how it is protected in transit and at rest, and what the deletion path
  is.
- **Authentication and authorization**: who the actors are, how each proves
  identity, and where every authorization check lives. Name the object-level
  checks explicitly: the breach is usually a valid user reading someone else's
  row, not an anonymous attacker.
- **Input and injection surfaces**: list every boundary where untrusted input
  enters - HTTP params, forms, uploads, CLI args, files on disk, webhooks,
  third-party responses, model output. For each, the validation rule and the
  safe construction used downstream: parameterised queries, output escaping, no
  shell string interpolation, no `eval`, path traversal on any filename, SSRF on
  any outbound fetch, XSS on anything rendered.
- **Dependencies and supply chain**: pinned versions, a committed lockfile, an
  audit command that runs in CI, and the rule for what happens when it reports a
  vulnerability.
- **Transport and configuration**: TLS everywhere, cookie flags, CORS, the
  security headers that apply, and every difference between the development and
  production configuration - especially debug modes, seeded data and default
  credentials.
- **Abuse and denial of service**: rate limits, payload size caps, timeouts, and
  what an attacker gains by hammering the most expensive endpoint.
- **Logging and incident response**: what is recorded for a security-relevant
  event, what is deliberately never recorded, and the first thing you would do
  on learning the app was compromised.

Then state the **threat model in one paragraph**: who would attack this, what
they want, and what you are explicitly *not* defending against. Say "a
compromised developer machine is out of scope" rather than pretending it is
covered.

Turn the outcome into work, not prose. Every gap becomes one of three things: a
task added to the Phase 3 list, a test added to the security level of the Phase
4 plan, or an entry in the risks section with the reason it is accepted. A
finding with no home is a finding you will forget.

**Gate**: show the review, the threat model and the tasks and tests it added.
The user accepts the residual risks explicitly - accepting risk is their call,
never yours.

---

## Phase 6 - Write PLAN.md

Fold Phases 1-5 into a single `PLAN.md` at the repository root. It is the
document someone reads to understand the project without reading the code, and
the one you re-read whenever the work drifts.

Follow [PLAN-TEMPLATE.md](PLAN-TEMPLATE.md) for the structure.

Rules for the document:

- Record decisions **with their reasoning**, and the alternatives rejected. A
  decision without a *why* gets re-litigated in three weeks.
- Mark every verified fact with the date it was verified.
- Keep the risks section honest: what could sink this, and what you would do
  about it.
- No hedging and no filler. If something is undecided, say so and say what would
  decide it.

If `PLAN.md` already exists, read it first and revise it in place rather than
overwriting it. Keep what is still true.

**Gate**: the user reads `PLAN.md` and approves it. This is the last cheap
moment to change direction.

---

## Phase 7 - GitHub with git flow

Set the repository up and then work it, following
[GIT-FLOW.md](GIT-FLOW.md) for the exact commands and the rules of each branch.

The shape of it:

1. **Confirm with the user before creating anything on GitHub**: repository
   name, visibility (private unless they say otherwise), and account/org.
   Creating a repository is outward-facing - ask first, every time.
2. **Bootstrap**: `git init`, `.gitignore`, `README.md`, `PLAN.md`, first commit
   on `main`, create the remote, push, branch `develop` off `main`, make
   `develop` the default branch.
3. **Per task**, in the Phase 3 order: branch off `develop`, write the tests from
   Phase 4 alongside the code, run the full suite, and only then open a PR into
   `develop`. A red suite never reaches `develop`.
4. **At the end of each milestone**, run the checks that need a running
   application rather than a test process: the performance measurement from
   Phase 4 (browser run, load run or timed run, as applicable), the manual QA
   checklist, and the dependency audit from Phase 5. Record the numbers in
   `PLAN.md` next to their budget, and open a task for every budget missed.
5. **Release**: when every milestone is done, the suite is green on `develop`
   and the budgets are met or their misses accepted, open a PR from `develop`
   into `main`, merge it, and tag the release.

`main` only ever receives merges from `develop`. Nothing is pushed to `main`
directly.

Keep `PLAN.md` current as you go: tick off tasks, and when reality contradicts
the plan, amend the plan in the same PR that contradicted it.
