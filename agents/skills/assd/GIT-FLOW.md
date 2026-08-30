# Git flow for assd

Two permanent branches:

- **`main`** — released, working code. Receives merges from `develop` only.
- **`develop`** — integration branch. Receives feature branches, each one tested
  and green before it lands.

Short-lived branches: `feature/<slug>` off `develop`. Use `fix/<slug>` for
repairs to something already on `develop`, and `release/<version>` only if the
release needs stabilising work of its own.

## 1. Bootstrap

Confirm the repository name, visibility and owner with the user before running
`gh repo create`. Default to private.

```bash
git init -b main
# .gitignore and README.md first, then:
git add . && git commit -m "chore: initial commit with PLAN.md"
gh repo create <name> --private --source=. --remote=origin --push
git switch -c develop
git push -u origin develop
gh repo edit --default-branch develop
```

Optional but recommended, and worth offering to the user: protect `main` so it
only takes reviewed PRs.

## 2. One feature at a time

```bash
git switch develop && git pull --ff-only
git switch -c feature/<slug>
```

Work the task from the plan. Write its tests alongside the code — the tests
Phase 4 assigned to this task, not whatever is convenient. Commit in small,
coherent steps, present tense, prefixed by type (`feat:`, `fix:`, `test:`,
`refactor:`, `docs:`, `chore:`).

Before the branch leaves your machine, run **the whole suite**, not just the new
tests. If it is red, it does not get pushed.

```bash
<the single test command from PLAN.md>
git push -u origin feature/<slug>
gh pr create --base develop --title "<task id>: <title>" --body "<what, why, tests run>"
```

The PR body names the task id from `PLAN.md`, what changed, and the evidence
that the suite passed. When CI is green, merge:

```bash
gh pr merge --squash --delete-branch
```

Report failures faithfully. A skipped test is a skipped test; say so in the PR
rather than calling the task done.

## 3. Release to main

When every milestone in `PLAN.md` is done and `develop` is green:

```bash
git switch develop && git pull --ff-only
<the single test command from PLAN.md>
gh pr create --base main --head develop --title "release: v<version>" --body "<changelog>"
gh pr merge --merge   # no squash: keep develop's history on main
git switch main && git pull --ff-only
git tag -a v<version> -m "v<version>" && git push origin v<version>
```

Then bring `main` back into `develop` if the merge added anything (a tag-only
release usually adds nothing).

## Rules that do not bend

- Nothing is pushed to `main` directly. Ever.
- Nothing reaches `develop` with a red or unrun suite.
- One task per branch. If a branch grows a second task, split it.
- The user confirms before the first `gh repo create`, before any force push,
  and before anything that rewrites published history.
