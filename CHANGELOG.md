# Changelog

All notable changes to this Claude Code config setup are documented here.

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
