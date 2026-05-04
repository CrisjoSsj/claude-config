# Project Detector — Cascading CLAUDE.md audit

> Comentario en español: regla CRÍTICA. Arranca al inicio de cada sesión en cualquier carpeta.
> Hace 3 pasos en cascada: raíz → top-level folders → submódulos.
> Si falta CLAUDE.md, lo crea. Si está stale, lo actualiza.
> Aplica a TODOS los proyectos siempre: nuevos, existentes, grandes, chicos.

## Activation (automatic)

Run on EVERY session start when cwd is a project root or any subdirectory of one.

Skip ONLY if user message contains: "no audit" / "skip setup" / "directo a X" / "no audites" / "saltáte el setup".

Skip if cache fresh: `mem_search(query: "project/{name}/audit", project: "{name}")` returns audit <7 days old AND no major structural change since.

## Detection Protocol (parallel, ~10 seconds)

Read 5 signals:
1. `ls` of cwd root.
2. `git log --oneline | head -5` (if .git exists).
3. Code file count (.py .ts .js .go .rs .java .swift .kt count).
4. Existence of CLAUDE.md.
5. Existence of .claude/.

Classify:
- **GREENFIELD**: empty OR only .git/ OR <5 code files OR 0-1 commits.
- **BROWNFIELD**: >5 code files AND >5 commits.
- **MIXED**: ask user "¿proyecto nuevo o continuando uno existente?".

If CLAUDE.md exists + .claude/ configured + last update <30 days → already bootstrapped. Load context, go to user's task.

## GREENFIELD Mode → Bootstrap Protocol

### Step 1: Short interview via AskUserQuestion (4 questions max)
1. **Project name** (free text).
2. **Expected size**: small (<20 files) / medium (20-200) / large (200+) / monorepo.
3. **Primary stack**: TypeScript / Python / Go / Rust / Java / Kotlin / Swift / Mixed.
4. **Type**: Web app / API / CLI / Library / Mobile / Backend service / Full-stack.

If all 4 answers in original message, skip interview.

### Step 2: Template selection
- small → `~/.claude/templates/small-project/`
- medium → `~/.claude/templates/medium-project/`
- large → `~/.claude/templates/large-project/`
- monorepo → `~/.claude/templates/monorepo/`
+ stack overlay from `~/.claude/templates/_stack-overlays/<stack>/`

### Step 3: Apply template (in order)
1. Root `CLAUDE.md` parameterized with name/stack/type.
2. `CLAUDE.local.md` template.
3. `.gitignore` with appended lines (CLAUDE.local.md, .claude/cache/, etc.).
4. `.claude/settings.json` with stack-aware hooks.
5. `.claude/agents/*.md` per stack + size.
6. `.claude/skills/*/SKILL.md` per size.
7. `.claude/commands/*.md` slash commands.
8. Initial folder structure (src/, tests/, docs/, per stack).
9. For large/monorepo: `docs/ARCHITECTURE.md`, `docs/GLOSSARY.md`, `docs/adr/0001-record-architecture-decisions.md`, `.github/PULL_REQUEST_TEMPLATE.md`.

### Step 4: Per-module CLAUDE.md (large/monorepo only)
For each main module created, generate Apple-style CLAUDE.md per `per-module-claude-md.md`.

### Step 5: Git init
```bash
git init
git add .
git commit -m "chore: bootstrap project structure with Claude config"
```

### Step 6: Engram save
topic_key: `project/<name>/bootstrap`
- Name, size, stack, type, decisions, files created, date.

### Step 7: Report to user (Spanish)
```
✅ Proyecto <nombre> bootstrapped (<tamaño>, <stack>, <tipo>)

📁 Estructura creada: <list>
🔒 Hooks activos: <list 3-5>
🤖 Agents: <list>
⚡ Slash commands: <list>

¿Arrancamos a codear, o querés ajustar algo del setup primero?
```

## BROWNFIELD Mode → Audit + Retrofit Protocol

### Step 1: Stack & architecture inference (no ask user)
- Detect stack from `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc.
- Infer architecture pattern from folder structure.
- Infer size by file count.

### Step 2: Audit in parallel (subagents)
Launch simultaneously:
- security-reviewer → secrets, OWASP risks
- refactor-cleaner → legacy, dead code, unused deps
- code-explorer → architecture, test coverage, CLAUDE.md gaps
- inline → git hygiene, doc state

Each reports findings in structured format.

### Step 3: Cascading CLAUDE.md audit (the key part)

**Step 3.1 — Root CLAUDE.md**
- Check `<project-root>/CLAUDE.md` existence.
- If MISSING: audit project, infer details, generate root CLAUDE.md (Apple-style, EN+ES).
  Include: identity, stack, glossary, root architectural decisions, no-touch list.
- If EXISTS but stale (>90 days OR major refactor since OR mentions modules that no longer exist):
  Update affected sections.

**Step 3.2 — Top-level folder CLAUDE.md**
For each first-level structural folder (`backend/`, `frontend/`, `mobile/`, `services/`, `packages/`, `apps/`, `libs/`, plus Spanish equivalents `móvil/`):
- If folder meets per-module-claude-md criteria AND has no CLAUDE.md → generate it.
- If has CLAUDE.md but stale → update.

**Step 3.3 — Submodule CLAUDE.md (recursive)**
For each top-level folder WITH CLAUDE.md, descend into structural subfolders:
- Apply same logic at depth N+1.
- Stop when:
  - <3 code files (no CLAUDE.md needed)
  - Folder is `tests/`, `docs/`, `__pycache__/`, `node_modules/`, `dist/`, `build/` (skip)
  - Depth > 5 (sanity stop)

### Step 4: Aggregated report (Spanish)
```
🩺 Diagnóstico de <project> completado:

🟢 Lo que está bien: <list>
🟡 Mejorable: <list>
🔴 Crítico: <list>

📋 Retrofit propuesto en 3 fases (no destructivo):

FASE 1 — Setup config (5 min, 0 riesgo):
  ✓ <list>

FASE 2 — Per-module CLAUDE.md (X min, 0 riesgo):
  ✓ <list>

FASE 3 — Cleanup crítico (X min, riesgo BAJO):
  ⚠ <list>

¿Arrancamos por Fase 1?
```

### Step 5: Apply phases (only with user OK per phase)
- NEVER apply Phase 3 without explicit OK per item.
- NEVER delete preexisting code without confirmation.
- NEVER apply all 3 phases auto.

### Step 6: Engram save
topic_key: `project/<name>/audit`
- Findings, phases applied, decisions, date.

## Format requirements for every generated CLAUDE.md (NON-NEGOTIABLE)

Every generated CLAUDE.md follows the Apple-style template from `per-module-claude-md.md`:
- H1, bullets, directives in **English** (IA processes as commands).
- Inline `<!-- -->` comments and `> Comentario:` lines in **Spanish** (for human reader).
- 5-12 bullets typical, 20 hard cap.
- No emojis, no marketing.

## Cache / re-audit policy

- After full audit, save state to Engram (topic_key: `project/<name>/audit`).
- Skip re-audit if last < 7 days AND no major structural change detected.
- "Major structural change" = git log shows commits with `refactor:` / `feat:` / `chore: restructure` since last audit.

## Apply forever

This rule applies to ALL projects forever. New, existing, big, small. No opt-out except per-session "no audit".

## Anti-patterns

- DO NOT modify production code during detection. Only read.
- DO NOT delete preexisting `_legacy_*` without explicit user OK.
- DO NOT apply retrofit "all at once". Always phased.
- DO NOT re-audit every session — use cache.
- DO NOT interrupt a concrete task. If user says "fix X", go to fix. Audit is offered, not imposed.
