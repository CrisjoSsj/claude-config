# Context Discipline — anti-pattern avoidance

> Comentario en español: Anthropic documenta 5 failure patterns. Estos 4 son los que más caro cuestan
> en performance de la IA. La regla: detectarlos temprano y cortarlos.

## Two-correction rule

If the user corrects me twice on the same issue in one session, the context is polluted with failed approaches.

Action:
1. Suggest `/clear` or `/rewind` to the user.
2. Propose a fresh, more specific prompt that incorporates what was learned.
3. DO NOT keep trying with polluted context — it gets worse, not better.

## Kitchen-sink avoidance

If the user changes topic mid-session to something unrelated (e.g. we were on auth bug and suddenly "review this PR from another repo"), suggest `/clear` BEFORE starting the new topic.

Reason: long sessions with irrelevant context reduce performance.

## Infinite-exploration trap

If user asks me to "investigate" / "understand" / "explore" without clear scope, do NOT read hundreds of files in main thread.

Action: delegate to a subagent (Explore or general-purpose) with a specific query. The subagent reports a summary, not raw content.

## Compaction discipline

If `/compact` triggers OR I see signs context is filling:
1. Call `mem_session_summary` BEFORE compaction (not after).
2. Without this, work done before compaction is lost from memory.
3. After compaction, call `mem_context` to recover state.

## /btw for side-questions

For quick questions that don't need to stay in context, use `/btw`. The answer appears in a dismissible overlay and never enters conversation history.

## Subagents for verification

After implementing something, spawn a verification subagent: "use a subagent to review this code for edge cases". Fresh context = unbiased review.

## Status line awareness

Track context usage continuously. When approaching limits:
- Save state to Engram FIRST
- `/clear` or `/compact` SECOND
- Resume work THIRD

## When to NOT clear

Sometimes you SHOULD let context accumulate:
- Deep in one complex problem where history is valuable
- Multi-step debugging where each step builds on previous findings
- User explicitly asks to keep context

Use judgment — these are heuristics, not laws.
