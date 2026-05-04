# Ask User Question — interview before big features

> Comentario en español: para features con muchas incógnitas, mejor entrevistar al usuario primero
> que asumir y construir lo equivocado. Anthropic recomienda este patrón para features grandes.

## When to use AskUserQuestion

Use the AskUserQuestion tool when:

- Feature has ≥3 technical unknowns I'd otherwise have to assume.
- User said "implement X" but X has multiple reasonable interpretations.
- Tradeoffs exist that user must decide (perf vs cost, simplicity vs flexibility).
- The change affects security, persistence, or external integrations.
- User is bootstrapping a new project (use it as part of project-detector cascade).

## Interview pattern

When invoking, structure interview as:

```
I want to build [user's brief description]. Before coding, I need to understand:

1. <technical question 1 with options>
2. <UI/UX question if applicable>
3. <edge case question>
4. <tradeoff question>

Don't ask obvious questions — focus on what I can't infer from the code.
```

## Hard limits on interview

- Max 4-5 questions per interview round.
- Each question with predefined options when possible (faster to answer).
- If still need more info, do a second round AFTER user confirms first round.
- NEVER ask questions answered in CLAUDE.md or visible in the codebase.

## After interview

1. Summarize answers in `SPEC.md` (if project has `docs/specs/`) or in conversation.
2. Confirm with user: "Plan based on your answers: <summary>. Right?"
3. Start fresh session for implementation (clean context, written spec to reference).

## Default options to offer

For common interview categories:

**Persistence**: "In-memory / SQLite local / Postgres / Supabase / Redis cache + DB"
**Auth**: "JWT in cookies / JWT in localStorage / Session-based / OAuth provider"
**API style**: "REST / GraphQL / RPC / WebSocket"
**State management**: "Zustand / Redux / Jotai / Context API / TanStack Query (server)"
**Deployment**: "Vercel / Cloudflare / Railway / AWS / Self-hosted"

## When NOT to use AskUserQuestion

- User explicitly said "decidí vos" / "tomá decisiones razonables".
- The decision is reversible and low-cost (just code it, change later if needed).
- The answer is obvious from project context (existing stack, existing patterns).
