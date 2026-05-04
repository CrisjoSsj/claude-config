---
name: audit-tech-debt
description: Scan project for technical debt across all categories, classify + prioritize, update docs/tech-debt.md registry.
---

Audit technical debt across the codebase per `~/.claude/rules/technical-debt-management.md`.

## Steps

1. Scan input scope (whole repo if `$ARGUMENTS` empty, else specific module/path).

2. For each tech debt category, run detection:

   ### Code debt
   ```bash
   # Files >800 lines
   find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.kt" \) -exec wc -l {} \; | awk '$1>800'

   # Functions >50 lines (heuristic)
   # Use language-specific tools: radon (Python), eslint complexity (TS/JS), gocyclo (Go), etc.

   # _legacy_* files
   find . -name "_legacy_*" -o -name "_old_*" -o -name "_deprecated_*" -o -name "*.bak"

   # Dead code (functions with zero call-sites)
   # Use language tools: vulture (Python), ts-unused-exports (TS), unused (Go).

   # Commented blocks >5 lines
   grep -rn -B0 -A0 -E "^[[:space:]]*#|^[[:space:]]*//" | (run script to find consecutive lines)

   # TODO/FIXME unresolved >90 days
   git log --all --pretty=format:"%H %ad" --date=short -G "TODO|FIXME" | (filter old commits)
   ```

   ### Test debt
   ```bash
   # Coverage report
   pytest --cov  # or jest --coverage, go test -cover, cargo tarpaulin

   # Flaky tests (last 30 runs)
   # Read CI history if available; else mark as "unknown"
   ```

   ### Dependency debt
   ```bash
   # Per-language outdated check
   npm outdated --json
   pip list --outdated --format=json
   cargo outdated
   go list -m -u all

   # Vulnerabilities
   npm audit --json
   pip-audit
   cargo audit
   ```

   ### Documentation debt
   - Per `claude-md-freshness.md`: scan all CLAUDE.md for stale refs.
   - Modules without CLAUDE.md that meet criteria (≥3 code files + structural significance).
   - ADRs missing for big decisions evident in git log (lots of refactor commits without ADR).

   ### Security debt
   - Run `security-auditor` agent (if available).
   - Grep for hardcoded secrets: `apikey|api_key|password|token|secret` near string literals.
   - Grep for SQL string concat: `f".*SELECT.*{.*}.*"` (Python f-strings in queries).
   - Grep for `MD5|SHA1` near password hashing.

   ### Performance debt
   - Per `performance-at-scale.md`: scan for N+1 patterns per ORM.
   - List endpoints without pagination (no `limit`/`cursor` in handler).
   - Cache without invalidation (cache.set without corresponding invalidate).

3. Classify each item:
   - **Category**: code | test | dependency | documentation | security | performance | infrastructure | knowledge | compliance | design
   - **Severity**: CRITICAL | HIGH | MEDIUM | LOW
   - **Impact**: 1-line description of business/technical risk.
   - **Effort**: estimated hours to fix.
   - **Recommended action**: from `cleanup-decision-tree.md` (eliminate / consolidate / refactor / rewrite / add tests / bump dep / generate doc).

4. Compute Tech Debt Score:
   - CRITICAL × 10 + HIGH × 5 + MEDIUM × 2 + LOW × 1.
   - Compare to last audit (delta).

5. Update `docs/tech-debt.md` registry:
   - For each item: TD-### unique ID + full classification + status (open/in_progress/resolved).
   - Diff from previous audit shown clearly.

6. Generate report in Spanish:

```
📊 Audit de deuda técnica de <scope>:

Score actual: <N> (era <M> hace <X> días → <delta>%)

🔴 CRITICAL (<n>):
- TD-NNN: <description>
- TD-NNN: <description>

🟠 HIGH (<n>): <count + 3-5 ejemplos>
🟡 MEDIUM (<n>): <count>
🟢 LOW (<n>): <count>

🎯 Quick wins (HIGH × LOW effort, total ~Xh):
- TD-NNN: <action> (Yh)
- TD-NNN: <action> (Yh)

📈 Progreso vs auditoría previa:
- Resolved: <n> items
- New: <n> items
- Changed severity: <n> items

¿Aplicamos los quick wins ahora? (sí | seleccionar cuáles | no, solo reporte)
```

7. If user accepts, apply quick wins per `cleanup-decision-tree.md`:
   - For each item, follow the decision tree.
   - Get explicit OK for destructive ops on preexisting code.
   - Verify tests pass after each fix.
   - Update `docs/tech-debt.md` with status changes.

8. Save audit to Engram: `project/{name}/tech-debt-audit/{date}` for trend tracking.

## Frequency

Recommend running:
- **Per PR**: scoped to the changed files (boy scout rule).
- **Weekly**: on each main module rotated.
- **Monthly**: full repo audit + sprint planning input.
- **Before major release**: full audit + zero-CRITICAL gate.
