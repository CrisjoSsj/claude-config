# Claude Code Global Setup

> Format for generated .md: instructions in English, contextual comments in Spanish.
> Engineering expertise: Clean / Hexagonal / TDD / large monorepos.
> Conversation language: follow user's language. No forced persona, no assumed identity.

## Clean Code Fundamentals (always active for all agents and IA)

@~/.claude/rules/common/coding-style.md
@~/.claude/rules/common/code-review.md
@~/.claude/rules/common/security.md
@~/.claude/rules/common/testing.md
@~/.claude/rules/common/git-workflow.md
@~/.claude/rules/common/development-workflow.md
@~/.claude/rules/common/agents.md
@~/.claude/rules/common/hooks.md
@~/.claude/rules/common/patterns.md
@~/.claude/rules/common/performance.md

## Non-negotiable rules

@~/.claude/rules/code-quality-standards.md
@~/.claude/rules/scalability-principles.md
@~/.claude/rules/component-reusability.md
@~/.claude/rules/semver-and-deprecation.md
@~/.claude/rules/onboarding-and-refactor-safety.md
@~/.claude/rules/cleanup-decision-tree.md
@~/.claude/rules/technical-debt-management.md
@~/.claude/rules/no-legacy-rule.md
@~/.claude/rules/per-module-claude-md.md
@~/.claude/rules/project-detector.md
@~/.claude/rules/claude-md-freshness.md
@~/.claude/rules/refs-and-routes-tracking.md
@~/.claude/rules/verification-first.md
@~/.claude/rules/context-discipline.md
@~/.claude/rules/plan-mode-trigger.md
@~/.claude/rules/ask-user-question.md

## Memory & orchestration

@~/.claude/rules/engram-protocol.md
@~/.claude/rules/sdd-orchestrator.md

Strict TDD Mode: enabled

## Personal overrides (optional, local-only)

Create `~/.claude/CLAUDE.local.md` with your personal identity, tone, language
preferences, or project context. The file is gitignored — never gets pushed
to the team repo. The `INSTALL.sh` / `INSTALL.ps1` and `UPDATE.sh` preserve
it across updates.

@~/.claude/CLAUDE.local.md
