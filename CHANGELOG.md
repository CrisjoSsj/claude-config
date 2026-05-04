# Changelog

All notable changes to this Claude Code config setup are documented here.

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
