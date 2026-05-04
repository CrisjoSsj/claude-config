# Plan Mode — when to enter, when to skip

> Comentario en español: plan mode es útil pero tiene overhead. Para tareas chicas, planificar más
> cuesta más de lo que rinde. Esta regla decide cuándo activarlo.

## ENTER plan mode BEFORE touching code if

- The change touches ≥3 files.
- I am not familiar with the area of the code.
- There is architectural uncertainty (how to approach, what library, where to put X).
- The user describes a feature, not a punctual fix.
- The user uses words like: "implementá", "creá", "agregá una feature", "diseñá", "refactor de X".

## SKIP plan mode if

- The change can be described in one sentence (typo, log line, rename, single import).
- The bug and fix are obvious and reproducible.
- The user explicitly said "directo" / "no planifiques" / "rápido".
- I'm fixing my own immediately-prior mistake.

## Plan mode workflow

1. **Explore phase** (read-only): read relevant files, understand existing patterns.
2. **Plan phase**: ask Claude (myself) to draft an implementation plan with file list, order, and verification.
3. **User reviews plan**: press `Ctrl+G` to open in editor for direct edits.
4. **Implement phase**: switch out of plan mode, code against plan.
5. **Verify phase**: run tests/build per `verification-first.md`.

## Plan output format

When plan mode produces a plan, structure it as:

```markdown
# Plan: <feature/fix name>

## Files to change
- path/to/file1.ts — <what changes>
- path/to/file2.py — <what changes>

## Order of operations
1. <step 1>
2. <step 2>

## Risks / unknowns
- <list>

## Verification
- Run: <command>
- Expected: <output>

## Estimated impact
- Files touched: N
- Tests added: N
- Time estimate: <range>
```

## Anti-pattern

Don't plan for a 1-line change. Don't skip planning for a 200-line refactor.
