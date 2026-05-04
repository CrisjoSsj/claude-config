# Changelog

All notable changes to this Claude Code config setup are documented here.

## [1.2.0] — 2026-05-03

### Added — ERP-grade support

**8 new ERP rules** in `claude-config/rules/erp/`:
- `domain-driven-design.md` — bounded contexts, aggregates, value objects, ACL, domain events
- `database-migration-safety.md` — EXPAND → BACKFILL → CONTRACT pattern for zero-downtime
- `compliance-pii.md` — GDPR / SOX / HIPAA / PCI-DSS detection, audit log, right-to-erasure
- `multi-tenancy.md` — tenant isolation invariants, RLS, customization patterns
- `i18n-money-time.md` — Money type (Decimal + currency), TZ at boundaries, locale formatting
- `state-machines-workflows.md` — explicit FSMs, approval chains, sagas, outbox pattern
- `cross-module-impact.md` — blast radius analysis, downstream consumer mapping
- `performance-at-scale.md` — N+1 prevention per ORM, query budgets, read replicas, caching

**New `erp-project/` template** with:
- 3 specialized agents: `compliance-auditor`, `migration-safety-reviewer`, `multi-tenancy-reviewer`
- 4 ERP skills: `add-bounded-context`, `audit-pii`, `impact-analysis`, `migration-safety-check`
- 4 slash commands: `/new-bounded-context`, `/audit-pii`, `/impact-analysis`, `/migration-check`
- Pre-configured for: bounded contexts, ADR system, business-rules registry, compliance docs

**`project-detector.md` updated**: auto-detects ERP signals (≥1000 files, migrations, multi-tenant patterns, compliance markers) and promotes `large` → `erp` template.

### Notes
- ERP rules are **NOT** loaded in the global CLAUDE.md — they only activate inside `erp-project/` template (lazy load via Claude Code's descendant CLAUDE.md mechanism), so non-ERP projects don't carry their weight.
- The 8 ERP rules add ~3500 lines of dense guidance, all in English directives + Spanish comments.

## [1.1.0] — 2026-05-03

### Changed (BREAKING for existing users? NO — safer)
- **`INSTALL.sh` / `INSTALL.ps1` are now NON-DESTRUCTIVE.** Existing user configs are preserved:
  - `CLAUDE.md`: marker-based merge (`<!-- claude-config:start/end -->`). Custom content outside markers preserved across updates.
  - `settings.json`: deep-merged. Your hooks, permissions, plugins, and custom keys are preserved alongside ours.
  - `rules/`: no-clobber. Same-named files you have are NEVER overwritten — we only add ours that don't exist. Conflicts are reported.
  - `templates/`: no-clobber. Your customizations preserved.
  - `agents/`, `skills/`, `commands/`, `plugins/`, `sessions/`, `cache/`: untouched.
- Added `tools/merge-settings.js` and `tools/merge-claude-md.js` Node helpers (Node ≥14 required).
- Smoke test added: simulates user with existing config, validates 10 preservation invariants.

### Added
- `CLAUDE.local.md` scaffold auto-created on fresh install (gitignored, for personal config).
- Detailed install summary showing what was preserved, merged, and added.

## [1.0.0] — 2026-05-03

### Added
- Modular `~/.claude/CLAUDE.md` (39 lines, 22 `@imports`).
- 13 modular rules in `rules/`:
  - `code-quality-standards.md`
  - `no-legacy-rule.md`
  - `per-module-claude-md.md`
  - `project-detector.md` (cascading audit)
  - `claude-md-freshness.md` (anti-drift + ADR)
  - `refs-and-routes-tracking.md`
  - `verification-first.md`
  - `context-discipline.md`
  - `plan-mode-trigger.md`
  - `ask-user-question.md`
  - `engram-protocol.md`
  - `sdd-orchestrator.md`
  - + `common/` rules (cross-language)
- 7 stack overlays: TypeScript, Python, Go, Rust, Java, Swift, Kotlin.
- 4 hook scripts (PreToolUse / PostToolUse / Stop).
- 4 project templates: small, medium, large, monorepo.
- ADR template + index per Microsoft Azure / AWS / Google standards.
- Bilingual format (English directives + Spanish comments).
- Apple-style per-module CLAUDE.md with 6-12 dense bullets.
- INSTALL.sh / INSTALL.ps1 / UPDATE.sh / verify-install.sh.

### Inspired by
- Anthropic Claude Code best practices.
- Apple's leaked CLAUDE.md (Chat / SAComponents modules).
- Microsoft Azure Well-Architected ADR pattern.
- AWS Prescriptive Guidance for ADRs.
- Google Cloud architecture documentation.
- DeepDocs / Dokken drift detection patterns.
