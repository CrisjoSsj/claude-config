# Setup oficial de Claude Code

> **Pegale este archivo a tu equipo / cuentas / PCs. Idéntico para todos. Sin variación.**

Para que todos trabajemos con las MISMAS reglas, hooks, agents, skills, templates y workflows, instalá el setup oficial. Es 1 comando, ~30 segundos, no rompe nada (hace backup automático).

## Instalación (elegí tu OS)

### macOS / Linux

```bash
git clone https://github.com/CrisjoSsj/claude-config ~/.claude-config && bash ~/.claude-config/INSTALL.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/CrisjoSsj/claude-config $env:USERPROFILE\.claude-config; & "$env:USERPROFILE\.claude-config\INSTALL.ps1"
```

## Qué hace el installer

1. Backup tu `~/.claude/` actual a `~/.claude.backup.<fecha>/`.
2. Symlink (o copia, según OS) `~/.claude/` → `~/.claude-config/claude-config/`.
3. Verifica con `tests/verify-install.sh` que todo cargó bien.
4. Imprime versión instalada + cambios respecto a la previa.

## Para actualizar (semanal o cuando avise el equipo)

```bash
cd ~/.claude-config && bash UPDATE.sh
```

## Qué te queda activo automáticamente

### Reglas globales (en `~/.claude/rules/`)

- **`code-quality-standards.md`** — Clean Code, naming, file size limits, SOLID/KISS/DRY/YAGNI, error handling, testing 80%+.
- **`no-legacy-rule.md`** — NUNCA conservar legacy / dead / duplicate / zombie code.
- **`per-module-claude-md.md`** — CLAUDE.md por módulo Apple-style (EN directives + ES comments).
- **`project-detector.md`** — cascada automática al abrir cualquier carpeta.
- **`claude-md-freshness.md`** — anti-drift, ADRs append-only.
- **`refs-and-routes-tracking.md`** — auto-update CLAUDE.md ante cambios estructurales.
- **`verification-first.md`** — test pasa O build compila O screenshot antes de "listo".
- **`context-discipline.md`** — two-correction rule, kitchen-sink avoidance.
- **`plan-mode-trigger.md`** — cuándo entrar/saltar plan mode.
- **`ask-user-question.md`** — interview antes de features grandes.
- **`engram-protocol.md`** — memoria persistente cross-session.
- **`sdd-orchestrator.md`** — Spec-Driven Development workflow.
- **Stack overlays**: typescript, python, go, rust, java, swift, kotlin (en `rules/stack/`).

### Hooks determinísticos (en `~/.claude/settings.json`)

- **PreToolUse**: bloqueo automático de writes a `.env`, `.pem`, `.key`, `secrets/`, `credentials/`.
- **PostToolUse**: auto-format (black/prettier/gofmt/rustfmt) + detección de cambios estructurales.
- **SessionStart**: recordatorio de reglas activas.
- **Stop**: validación de drift de CLAUDE.md antes de cerrar sesión.

### Templates de proyectos (en `~/.claude/templates/`)

- **small-project**: <20 archivos, MVP, prototipos.
- **medium-project**: 20-200 archivos, app de producción.
- **large-project**: 200+ archivos con Apple-style CLAUDE.md por módulo + `docs/adr/` + ADR-0001 + `.github/PULL_REQUEST_TEMPLATE.md`.
- **monorepo**: multi-package coordinado.
- **_stack-overlays**: TS, Python, Go, Rust, Java, Swift, Kotlin.

### Slash commands (en templates `.claude/commands/`)

- **`/new-adr`** — Crea ADR con auto-numbering, actualiza índice.
- **`/audit-freshness`** — Audita drift en todos los CLAUDE.md del repo.
- **`/refactor-by-layers`** — Aplica refactor Hexagonal/Clean (split por capas).

### Skills (en templates `.claude/skills/`)

- **add-module** — Genera módulo nuevo con CLAUDE.md + tests skeleton (RED) + ADR si aplica.
- **pre-merge-check** — lint + types + tests + build + security + freshness antes de PR.
- **audit-module** — Audita módulo específico por legacy / dead / drift.

### Agents (en templates `.claude/agents/`)

- **code-reviewer** — Review de calidad / seguridad / mantenibilidad.
- **security-auditor** — OWASP Top 10 + secrets + auth flaws.

## Comportamiento que vas a notar inmediatamente

1. Abrís Claude Code en cualquier carpeta → audita automático en 2 min, te dice qué hacer.
2. Tocás un módulo sin CLAUDE.md → te lo crea Apple-style en mismo commit.
3. Movés / renombrás archivos → CLAUDE.md afectados se actualizan solos.
4. Tomás decisión arquitectónica grande → genera ADR en `docs/adr/` automático.
5. Generás código zombie / dead / legacy → NO lo permite (lo elimina o pregunta).
6. Intentás escribir un `.env` → el hook lo BLOQUEA antes de que pase.
7. Editás un `.py` o `.ts` → auto-format con black/prettier al guardar.
8. Cerrás sesión → check de freshness reporta drift si hay.

## Reglas innegociables (compartidas por TODO el equipo)

- ❌ Sin código legacy / muerto / duplicado / comentado-out.
- ✅ CLAUDE.md por módulo cuando corresponde (Apple-style, EN+ES bilingüe).
- ✅ Verificación obligatoria antes de declarar "listo" (test pasa O build compila O screenshot).
- ✅ TDD strict: RED → GREEN → IMPROVE.
- ✅ 80% coverage mínimo.
- ✅ ADR para decisiones grandes (append-only, supersede no edit).
- ✅ Auto-update de CLAUDE.md ante cambios estructurales.
- ✅ Hook bloquea archivos sensibles (`.env`, `.pem`, `.key`).

## Si tenés tu propia config personal extra

Poné tus reglas personales en `~/.claude/CLAUDE.local.md` (el installer lo respeta y NO lo sobrescribe). Aplican junto con las del equipo.

## Soporte / dudas

- Issues: github.com/CrisjoSsj/claude-config/issues
- Owner: [@CrisjoSsj](https://github.com/CrisjoSsj)
- Versión actual: 1.0.0

## Verificación post-install

```bash
bash ~/.claude-config/tests/verify-install.sh
```

Output esperado:

```
✅ ~/.claude/CLAUDE.md → 39 líneas, 22 imports OK
✅ ~/.claude/rules/ → 13 archivos cargados
✅ ~/.claude/rules/stack/ → 7 stack overlays
✅ ~/.claude/settings.json → 4 hooks activos
✅ ~/.claude/scripts/ → 4 scripts ejecutables
✅ ~/.claude/templates/ → 4 tamaños listos

Setup v1.0.0 instalado correctamente.
```

Si el verify falla, pegame el output completo en el chat del equipo.

---

**Cualquier mejora a las reglas pasa por `git push` al repo + `UPDATE.sh` en cada máquina. Así garantizamos sincronía total sin variaciones.**
