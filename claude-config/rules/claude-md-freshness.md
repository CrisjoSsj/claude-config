# CLAUDE.md Freshness — anti-drift system

> Comentario en español: esta regla evita que los CLAUDE.md se queden desactualizados.
> Aplica en 3 capas: hook reactivo, cascada al inicio de sesión, ADR para decisiones grandes.
> Patrón industria: Microsoft Azure ADR, AWS Prescriptive Guidance, Apple rdar:// anchoring.

## Capa 1: After every structural change (mandatory)

After ANY Write/Edit that produces a structural change, update the affected CLAUDE.md(s) in the SAME commit.

Structural change triggers:
- New / deleted / moved file in a module
- Public interface change (exports, public functions, type signatures)
- New workaround with TODO/FIXME/issue link
- New environment variable / feature flag
- Architectural decision (consider also generating ADR)
- Inter-module contract change

What to update:
- Add bullet for new decision/convention/workaround
- Remove bullets describing removed code
- Update non-obvious gotchas if behavior changed
- Update tickets/refs section if new workaround added

The PostToolUse hook (`detect-structural-change.js`) emits a stderr warning when it detects this. The IA reads stderr and is OBLIGATED by this rule to update affected CLAUDE.md.

## Capa 2: Cascading staleness audit at session start

(Handled by `project-detector.md` cascade.)

Staleness signals:
- CLAUDE.md mentions modules that no longer exist → STALE
- Physical modules meeting criteria without CLAUDE.md → MISSING
- Last edit of CLAUDE.md predates last module commit by >90 days → STALE
- @import paths in root CLAUDE.md point to non-existent files → BROKEN

Report each in audit output. Propose fix per-item.

## Capa 3: ADR (Architecture Decision Record) for big decisions

When a decision is "big", generate an ADR INSTEAD of just adding a bullet to CLAUDE.md.

A decision is "big" when ANY of:
- Affects ≥2 modules
- Changes a public contract (API, schema, protocol)
- Hard to reverse (database migration, framework change, paradigm shift)
- Affects security / performance / cost significantly

ADR template (saved to `docs/adr/NNNN-<slug>.md`):

```markdown
# ADR-NNNN: <Title in English>

> Comentario en español: <una línea explicando la decisión y su impacto>

## Status
proposed | accepted | deprecated | superseded by ADR-NNNN

## Date
YYYY-MM-DD

## Context
<what forced this decision — in English>
<!-- Comentario en español: <contexto extra para humanos> -->

## Decision
<what we decided — in English, imperative voice>
<!-- Razón: <español> -->

## Alternatives considered
- **<Alternative 1>**: <why rejected>
- **<Alternative 2>**: <why rejected>

## Consequences
- **Positive**: <list>
- **Negative**: <list>
- **Neutral**: <list>

## References
- <link to commits, PRs, docs>
```

ADR rules (industry standard from Microsoft Azure / AWS / Google Cloud):
- **Append-only.** NEVER edit an accepted ADR.
- If decision changes, create a NEW ADR with status "supersedes ADR-NNNN".
- Update old ADR's status to "superseded by ADR-MMMM" with link.
- Sequential numbering, never reused.
- Living index in `docs/adr/README.md` regenerated on each new ADR.

## Root CLAUDE.md keeps the ADR INDEX, not the decisions

```markdown
## Architectural decisions
- See `docs/adr/` for full decision history.
- Currently accepted ADRs:
  - ADR-0007: JWT refresh strategy (httpOnly cookies, 15m+7d windows)
  - ADR-0012: Use Redis for session cache
  - ADR-0023: Hexagonal architecture for backend/
```

## Auto-generation triggers for ADR

Generate an ADR automatically when:
- I make/propose an architectural decision affecting ≥2 modules.
- User says "esto es una decisión grande" / "esto va a cambiar mucho cosas" / "decision arquitectónica".
- Refactor crosses module boundaries (e.g. extracting a service).
- Stack change (changing ORM, framework, etc.).

## /new-adr command

The slash command `/new-adr` (defined in `~/.claude/commands/new-adr.md`) creates a new ADR with auto-numbering, opens it for filling, and updates the index.

## Stop hook validation

`check-claude-md-freshness.js` runs on Stop:
- Grep all CLAUDE.md for path/route mentions.
- Verify each path/route still exists.
- Report broken references before session closes.
- If ADR exists but root CLAUDE.md doesn't list it → flag.
