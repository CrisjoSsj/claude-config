---
description: Scan for tech debt across all categories, update registry, propose quick wins
---

Invoke the `audit-tech-debt` skill on the path provided as `$ARGUMENTS`, or whole project if empty.

Per `~/.claude/rules/technical-debt-management.md`:
1. Scan all categories (code, test, dependency, doc, security, perf, design, knowledge).
2. Classify + prioritize via impact×effort matrix.
3. Update `docs/tech-debt.md` registry with diff from previous audit.
4. Report summary in Spanish with CRITICAL/HIGH/MEDIUM/LOW breakdown.
5. Propose quick wins (HIGH impact × LOW effort).
6. Apply only with explicit user OK per item if destructive on preexisting code.
