---
description: Audit CLAUDE.md freshness across the entire repo
---

Run a comprehensive CLAUDE.md drift audit on the current project.

Steps:

1. Find all CLAUDE.md files in repo (excluding node_modules, .venv, dist, build).
2. For each:
   - Verify `@import` paths still exist.
   - Verify file paths mentioned in code blocks still exist.
   - Check last edit date vs module's last commit (>90 days = stale).
3. Find modules without CLAUDE.md that meet criteria (≥3 code files + structural significance).
4. Report findings in Spanish:
   ```
   📋 Audit de freshness completado:
   - X CLAUDE.md OK
   - Y stale (necesitan update)
   - Z módulos sin CLAUDE.md (cumplen criterios)
   - W con referencias rotas

   ¿Aplicar fixes? (sí | revisar primero | no)
   ```
5. Si user dice "sí", aplicar fixes en commits separados por categoría.
6. Save audit result to Engram (`project/<name>/audit`).
