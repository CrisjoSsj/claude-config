---
name: audit-module
description: Audit a specific module for legacy/dead/duplicate code and CLAUDE.md drift.
---

Audit the target module (or current cwd if not specified).

Steps:

1. Identify target module from user or cwd.
2. Run grep for legacy markers:
   - `_legacy_*`, `_old_*`, `_deprecated_*`, `_archived_*`
   - `*.bak`, `*.copy.*`, `*_v2.*`, `*_new.*`
   - `# TODO: borrar`, `# DEPRECATED`, `# UNUSED`
   - `if False:`, large commented blocks
3. Find functions/classes/imports without call-sites:
   ```bash
   # Per language: grep for definitions, then check usage
   ```
4. Detect duplicates: same function name across multiple files.
5. Check CLAUDE.md freshness for this module:
   - Mentions of paths that no longer exist
   - Missing CLAUDE.md if criteria met
6. Report in Spanish:
   ```
   🩺 Audit de <module>:

   🟢 OK:
   🟡 Mejorable:
   🔴 Crítico:

   ¿Borro / consolido / dejo? (per item)
   ```
7. Apply fixes only with user OK per item.
8. Save to Engram: `project/{name}/audit/{module}`.
