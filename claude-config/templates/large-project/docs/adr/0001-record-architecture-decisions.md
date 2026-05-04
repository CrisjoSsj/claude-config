# ADR-0001: Record architecture decisions

> Comentario en español: este es el meta-ADR que explica por qué usamos ADRs.

## Status
accepted

## Date
{{DATE_TODAY}}

## Context
Architectural decisions need to be tracked and remembered. Without a record, future developers (and AI) can't understand why X was chosen over Y, leading to silent regressions when "improvements" undo earlier decisions.

<!-- Comentario en español: cuando alguien rehace una decisión sin saber el contexto histórico,
     suele revertir un workaround intencional. Los ADRs lo evitan. -->

## Decision
We use Architecture Decision Records (ADRs) per the lightweight Markdown format described by Michael Nygard.

ADRs live in `docs/adr/` with sequential numbering (`NNNN-<slug>.md`). Each ADR captures:
- Status (proposed | accepted | deprecated | superseded)
- Date
- Context (forces at play)
- Decision (what was chosen)
- Alternatives considered (with rejection reasons)
- Consequences (positive, negative, neutral)

ADRs are **append-only**: never edit accepted ADRs. To change a decision, create a new ADR with status `supersedes ADR-NNNN` and update the old ADR's status to `superseded by ADR-MMMM`.

The root `CLAUDE.md` lists currently accepted ADRs but does NOT duplicate their content.

## Alternatives considered
- **Wiki / Confluence**: rejected — not versioned with code, drifts.
- **Comments in code**: rejected — too granular, easily lost.
- **README sections**: rejected — README isn't append-only friendly.

## Consequences

**Positive:**
- Decisions traceable over time.
- New devs / AI can ramp up on architecture quickly.
- Forces explicit reasoning (what alternatives were rejected).

**Negative:**
- Adds documentation overhead per decision.
- Requires discipline to actually write them.

**Neutral:**
- Industry standard (Microsoft Azure, AWS, Google Cloud all recommend this).

## References
- https://adr.github.io/
- https://martinfowler.com/bliki/ArchitectureDecisionRecord.html
- https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/
