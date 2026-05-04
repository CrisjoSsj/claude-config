# Cleanup Decision Tree — Eliminate / Consolidate / Refactor / Rewrite

> Comentario en español: cuando hay código zombie, duplicado, legacy o mal diseñado,
> esta regla decide QUÉ hacer (eliminar, consolidar, refactor interno, reescribir).
> Aplica a CUALQUIER cleanup en cualquier proyecto, especial relevancia en ERPs viejos.

## Default priority order (from cheapest/safest to most expensive/risky)

1. **Eliminate** — cheapest. If no one uses it, delete.
2. **Consolidate** — cheap when tests cover call-sites. Merge duplicates.
3. **Refactor (internal)** — preserves public signature. Low blast radius.
4. **Rewrite + deprecation cycle** — most expensive. Last resort.

ALWAYS prefer earlier options when applicable. Only escalate when the cheaper option doesn't solve the problem.

## Decision tree (apply in order)

```
START: Found problematic code (zombie/duplicate/bad-design)
│
├─ Q1: Are call-sites = 0 (in grep + reflection + dynamic loads)?
│    └─ YES → ELIMINATE (per no-legacy-rule.md)
│       └─ Note: verify dynamic dispatch, plugin systems, config-driven calls first
│
├─ Q2: Is it identical (or near-identical) to another function?
│    └─ YES → CONSOLIDATE (keep best version, redirect call-sites, delete others)
│
├─ Q3: Is it the same logic with a different API shape?
│    └─ YES → CONSOLIDATE to best API + DEPRECATE the others (semver cycle)
│
├─ Q4: Is the function used heavily (>5 call-sites) AND signature is OK BUT internals are bad?
│    └─ YES → REFACTOR INTERNAL (keep signature, fix implementation)
│
├─ Q5: Is the function used lightly (≤5 call-sites) AND has bad signature/design?
│    └─ YES → REWRITE NEW + migrate call-sites + delete old
│
├─ Q6: Is the entire module's structure broken (flat, mixed concerns, no layers)?
│    └─ YES → REFACTOR BY LAYERS (hexagonal split, /refactor-by-layers command)
│
└─ Q7: Is there NO test coverage for this code?
     └─ YES → STOP. Add characterization tests FIRST, then re-enter the tree.
```

## Decision matrix

| Situation | Tests pass | Call-sites | Public API? | Action | Risk |
|---|---|---|---|---|---|
| 3+ identical funcs in repo | ✅ | any | no | **Consolidate** to one | low |
| Same logic, different APIs | ✅ | any | no | **Consolidate** + deprecate | low |
| `_legacy_*` / `_old_*` zero call-sites | n/a | 0 | n/a | **Eliminate automático** (no-legacy rule) | none |
| `_legacy_*` with ≥1 call-sites | ✅ | ≥1 | maybe | **Investigate** — may be intentional. Report + ask | medium |
| Function with bad internals, used widely | ✅ | >5 | maybe | **Refactor internal** (keep signature) | low |
| Function with bad signature, used lightly | ✅ | 1-5 | no | **Rewrite + migrate** | low |
| Function with bad signature, used widely | ✅ | >5 | yes (public API) | **Rewrite NEW + deprecate OLD** (semver cycle, ≥2 releases) | medium |
| Module flat / mixed concerns | ✅ | any | n/a | **Refactor by layers** (hexagonal) + ADR | medium |
| Code with zero test coverage | ❌ | any | any | **Add characterization tests FIRST** | n/a |
| Critical path (payments, auth, billing) | any | any | any | **Pause. Pair with senior. Tests + ADR mandatory** | high |
| Code "preserved for legacy system X" | n/a | maybe | n/a | **Verify system X exists** before deciding | varies |

## Heuristics

### "Eliminate > Consolidate > Refactor Internal > Rewrite"

The default order. Always apply Q1 first (free safety check), Q2 next (cheap consolidation), then escalate.

### Rule of three (DRY)

Don't extract / consolidate until 3 concrete uses. Two uses = wait. One use = never.

### Rule of zero call-sites = automatic deletion

If `git grep` + `find references` shows 0 hits AND no dynamic loading exists → eliminate without asking.

### Rule of "tests as safety net"

NEVER refactor / rewrite without tests covering the area. If coverage <70%, add **characterization tests** that lock in current behavior FIRST, then refactor.

```python
# characterization test = "test what the code does today, even if buggy"
def test_legacy_calc_total_includes_negative_discounts():
    # Locks in current (possibly weird) behavior so refactor doesn't change it accidentally.
    assert calc_total([100, -20, 50]) == 130
```

After refactor, these tests still pass = behavior preserved.

### Public API requires deprecation cycle

If touching a function/class/module that has external consumers (other teams, libraries, mobile clients):
- Cannot just rewrite + delete. Apply 2-cycle deprecation per `semver-and-deprecation.md`.
- Cycle 1: announce (MINOR release with `@deprecated` warning).
- Cycle 2: remove (MAJOR release with breaking change in CHANGELOG).

### Critical paths require extra scrutiny

For `payments/`, `auth/`, `billing/`, `audit_log/` — even with green tests, refactors here need:
- Pair review (or in IA case: explicit user approval + ADR).
- Property-based tests if applicable.
- Staged rollout (feature flag + small % traffic first).

## Common ERP cleanup scenarios

| Pattern in old ERP | Recommended action |
|---|---|
| `helpers.py` / `utils.js` / `Common.cs` of 5000+ lines mixing everything | **Split by concern** (date_utils, money_utils, string_utils). Consolidate duplicates. NOT a rewrite — just reorganization. |
| Multiple versions of same calc (`calcTotal`, `calculateTotal`, `compute_total_v2`) | **Consolidate to one** + deprecate others with cycle |
| Business logic inside controllers/views/templates | **Refactor by layers**: extract to application service. Endpoint signature unchanged. |
| Functions with `# TODO: refactor this` from years ago | **Rewrite now**. The old TODO is a signal of provisional code that calcified. |
| Code commented out >5 lines | **Eliminate** — git history has it (no-legacy rule). |
| "Kept for legacy system X integration" | **Verify** system X is still alive. If not → eliminate. If yes → keep + comment + ADR. |
| Sub-module with 1 file of 3000 lines | **Split** by responsibility (this is reorganization, not rewrite). |
| Functions/classes that exist but no one imports | **Eliminate** automatic if no dynamic dispatch found. |
| Old API maintained for backwards compat | **Verify clients** still need it. If yes → keep + deprecate plan. If no → remove. |
| Two modules doing similar things (e.g. `customer_v1/`, `customer_v2/`) | **Consolidate** to v2 (or pick the better one) + migrate v1 callers + delete v1 |
| Magic strings / numbers everywhere | **Extract to constants module** (consolidation, not rewrite) |
| Inheritance hierarchy 4+ deep | **Refactor to composition** (likely a partial rewrite of those classes) |

## What NOT to do

- ❌ "Big bang rewrite" of an entire module. Almost always kills the project. Always incremental.
- ❌ Rewrite without measuring (is it actually slow? is the bug real?). Premature.
- ❌ Consolidate functions that "look the same" without verifying behavioral equivalence.
- ❌ Eliminate based only on grep — verify dynamic loading, reflection, config-driven calls, plugin systems.
- ❌ Refactor critical path without pair review + tests + staged rollout.
- ❌ Rewrite with no characterization tests. Subtle behaviors get lost.
- ❌ Mix refactor + new feature in same commit. Always separate.
- ❌ Ship breaking changes without semver bump + deprecation cycle.

## Workflow per cleanup item

For each problematic code item, the IA must:

1. **Classify** using the decision tree (Q1 → Q7).
2. **Verify safety**:
   - Tests exist? Pass on main?
   - Call-sites identified (grep + dynamic dispatch check)?
   - Public API impact analyzed (`/impact-analysis` skill)?
3. **Report to user** with: pattern detected, recommended action, risk level, alternatives.
4. **Wait for OK** if action is destructive AND code is preexisting (per no-legacy-rule.md).
5. **Execute** with tests as safety net. Each step a separate commit.
6. **Verify** post-step: tests pass, build OK, CLAUDE.md updated.
7. **Save findings** to Engram (`project/{name}/cleanup/{date}/{item-id}`).

## Reporting format (mandatory)

```
🧹 Cleanup item #N: <description>

**Pattern**: <duplicate | dead-code | bad-design | mixed-concerns | other>
**Location**: <file:line>
**Call-sites**: <N> (in <list of files>)
**Test coverage**: <X% | "no tests"> on this code
**Public API**: <yes | no | unclear>

**Recommended action**: ELIMINATE | CONSOLIDATE | REFACTOR_INTERNAL | REWRITE | REFACTOR_BY_LAYERS
**Reasoning**: <one-line>

**Steps to execute**:
1. ...
2. ...

**Risk level**: low | medium | high
**Reversibility**: ✅ git revert OR ⚠️ irreversible after migration

**Alternatives considered**:
- <alt 1>: rejected because <reason>
- <alt 2>: rejected because <reason>

¿Aplico? (sí | no | dejá para después | mostrame más detalle)
```
