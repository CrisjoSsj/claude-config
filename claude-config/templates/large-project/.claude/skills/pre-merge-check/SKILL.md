---
name: pre-merge-check
description: Run lint + tests + build + security scan + freshness check before opening PR.
---

Comprehensive pre-merge validation. Run BEFORE opening a PR.

Steps:

1. **Lint**: run project linter (`pnpm lint` / `ruff check` / `golangci-lint` / etc.).
2. **Type check**: `tsc --noEmit` / `mypy --strict` / `cargo check`.
3. **Tests**: full test suite + coverage report.
4. **Build**: production build to verify it compiles.
5. **Security scan**: `npm audit` / `bandit` / `cargo audit`.
6. **CLAUDE.md freshness**: invoke `/audit-freshness` to verify no drift.
7. **No legacy check**: grep for `_legacy_*`, `_deprecated_*`, `_old_*`, `if False:`, `# TODO: borrar` in changed files.
8. **Commit hygiene**: verify commit messages follow `<type>(<scope>): description`.

Aggregate report:

```
✅ Lint: passed
✅ Types: passed
✅ Tests: 142 passed, coverage 87%
❌ Build: failed (see error)
✅ Security: 0 high/critical
⚠️  CLAUDE.md: 1 stale file detected
✅ No legacy code in changes
✅ Commits clean

🚦 Ready to merge: NO (build failed)
```

If all green: report "ready to merge" + suggest PR description.
If any fail: report blockers + suggest fixes per failure.
