---
description: Create a new Architecture Decision Record with auto-numbering
---

Create a new ADR in `docs/adr/`.

Steps:

1. Read `docs/adr/README.md` to find the highest existing ADR number.
2. Compute next number: `NNNN = max + 1`, zero-padded to 4 digits.
3. Ask user (or infer from context) the ADR title.
4. Generate slug from title: lowercase, dashes, no special chars.
5. Create file `docs/adr/NNNN-<slug>.md` using the template from `~/.claude/rules/claude-md-freshness.md`.
6. Fill template:
   - Status: `proposed` (user can promote to `accepted` later).
   - Date: today's date.
   - Context, Decision, Alternatives, Consequences (interview user if not given).
7. Update `docs/adr/README.md` index table.
8. Update root `CLAUDE.md` "Currently accepted ADRs" list.
9. Save to Engram with topic_key `project/{name}/adr/{NNNN}`.
10. Report to user with file path and proposed status.

If user provides arguments after `/new-adr`, use them as the title.
