# Onboarding & Refactor Safety

> Comentario en español: cómo hacer que la IA (o un dev humano nuevo) sea productiva
> en horas, no semanas. Y cómo refactorizar sin romper código que importa.

## Onboarding protocol (when AI/dev enters a new repo)

When the IA starts work on a project for the first time (or after a long gap), follow this sequence BEFORE writing code:

### Step 1: Read the orientation files (in order, ≤15 min)

1. **Root `CLAUDE.md`** — identity, stack, decisions, no-touch zones.
2. **`README.md`** — quickstart, install, run, test, deploy.
3. **`docs/ARCHITECTURE.md`** if it exists — high-level diagram, module boundaries.
4. **`docs/GLOSSARY.md`** if it exists — domain language.
5. **Latest 3-5 ADRs** in `docs/adr/` — recent architectural decisions.
6. **Top-level folder structure** — `ls` of root + `ls` of each first-level folder.

### Step 2: Trace one happy path (≤30 min)

Pick ONE realistic user journey (e.g., "user signs in", "order is placed") and follow it through the code:

- Entry point (route handler, CLI command, queue consumer).
- Application service / use case.
- Domain logic.
- Persistence (repo, ORM).
- External calls (events, HTTP).

This grounds your mental model in real flow, not abstract structure.

### Step 3: Identify the "danger zones" before touching code

Skim:
- `git log --since="3 months ago" --grep="hotfix\|revert\|rollback"` — recent fires.
- `git log -- <file>` for any file you're about to edit (5 most recent commits).
- TODO / FIXME / HACK markers in the touched area.
- Any `_legacy_*` / `_old_*` files (per `no-legacy-rule.md`, report them).

### Step 4: Verify your assumptions cheaply

Before making changes:
- Run the test suite once (does it pass on main?).
- Run the build (does it compile?).
- Check ADRs for the area — were the patterns intentional?
- If something looks wrong, ASK before "fixing" — it might be a workaround for a known issue.

## Knowledge inheritance (across sessions)

When session ends, future sessions need to inherit knowledge:

- **`mem_session_summary`** at session end (per `engram-protocol.md`).
- **CLAUDE.md updates** for any decision made.
- **ADR** for big decisions.
- **Comments** for non-obvious why's (per `code-quality-standards.md`: comment WHY, never WHAT).

## Refactor safety protocol

A safe refactor changes structure without changing observable behavior. To guarantee that:

### Pre-refactor checklist

- [ ] Tests covering the area pass on main (the safety net).
- [ ] If coverage of target area is < 70%, add characterization tests FIRST. They lock in current behavior.
- [ ] Define the END state explicitly (CLAUDE.md update, ADR, or comment).
- [ ] Identify blast radius (`/impact-analysis` skill if available).
- [ ] Decide reversibility: can this be reverted with `git revert`? Or are there one-way doors (DB schema, API change)?
- [ ] If one-way: split into smaller, individually-revertible steps.

### During refactor

1. **Small steps.** Each commit changes ONE thing. Tests pass after EACH commit.
2. **Mechanical first, behavioral second.** Move/rename in commit A. Behavior change in commit B.
3. **Keep tests green.** If tests break after a step, revert and split smaller.
4. **No code changes inside the moved code.** When you `git mv` a file, change ONLY the location in that commit. Logic edits in a separate commit.

### Post-refactor verification

- [ ] Full test suite passes (unit + integration + E2E).
- [ ] Build compiles.
- [ ] Manual smoke test of the happy path.
- [ ] CLAUDE.md updated (per `claude-md-freshness.md`).
- [ ] ADR generated if architectural (per `claude-md-freshness.md`).
- [ ] No `_legacy_*` files left behind (per `no-legacy-rule.md`).
- [ ] Imports across the repo still resolve (per `refs-and-routes-tracking.md`).

## When NOT to refactor

- **Just before a release deadline.** Risk too high; ship first, refactor after.
- **Without tests.** Add characterization tests first.
- **For aesthetics only.** "I don't like this style" is not a reason. Save it for the next planned cleanup window.
- **If you're not the owner.** Coordinate with the team that owns the area.
- **If the change is one-way and you're uncertain.** Ask first.

## Refactor patterns by scope

### Tiny (≤1 file, ≤30 min)
Examples: rename variable, extract function, simplify conditional.
- No need for plan mode.
- Tests as safety net.
- Single commit.

### Small (1-5 files, <1 day)
Examples: extract helper module, rename module, split large file.
- Use plan mode (per `plan-mode-trigger.md`).
- Update CLAUDE.md in same commit.
- Run impact analysis if public API touched.

### Large (10+ files, hexagonal split, multi-day)
Examples: bounded context split, ORM swap, API redesign.
- Generate ADR proposing the change.
- Get user/team OK before starting.
- Branch per phase; each phase merges separately.
- Keep main green throughout.

## Anti-patterns

- ❌ "Big bang" refactor (one PR rewriting 50 files). Always incremental.
- ❌ Refactor + new feature in same commit. Always separate.
- ❌ Refactor without test coverage. Add characterization tests first.
- ❌ Renaming files without updating CLAUDE.md / imports / docs.
- ❌ "Cleanup" PRs that touch unrelated code (scope creep).
- ❌ Refactoring code you don't understand. Read first, then refactor.
- ❌ Skipping post-refactor verification because "tests passed mid-way".

## Onboarding checklist (sign-off before declaring "ready to ship features")

- [ ] Read root CLAUDE.md, README, ARCHITECTURE.md, GLOSSARY.md, last 5 ADRs.
- [ ] Traced one happy path end-to-end.
- [ ] Test suite runs locally and passes.
- [ ] Build runs locally and passes.
- [ ] Identified danger zones (recent hotfixes, legacy markers).
- [ ] Saved key findings to Engram (`project/{name}/onboarding`).
- [ ] Updated `CLAUDE.local.md` if any personal config needed.
