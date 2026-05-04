# claude-config

> Setup oficial de Claude Code.
> Idéntico para todos. Sin variación. Sincroniza con un comando.

> **v1.1.0**: el installer ahora es **100% no-destructivo**. Si ya tenés `~/.claude/CLAUDE.md`, hooks, permissions, agents, skills o rules propias, NADA se sobreescribe — todo se mergea o preserva. Backup automático antes de cualquier cambio.

## Quickstart

### macOS / Linux

```bash
git clone https://github.com/CrisjoSsj/claude-config ~/.claude-config && bash ~/.claude-config/INSTALL.sh
```

### Windows (PowerShell como Admin)

```powershell
git clone https://github.com/CrisjoSsj/claude-config $env:USERPROFILE\.claude-config; & "$env:USERPROFILE\.claude-config\INSTALL.ps1"
```

Eso es todo. En 30 segundos, tu `~/.claude/` queda configurado con las mismas reglas, hooks, agents, skills, templates y workflows que el resto del equipo.

## Qué incluye este setup

### 13 reglas modulares (`rules/`)

| Regla | Para qué |
|---|---|
| `code-quality-standards.md` | Clean Code: SOLID/KISS/DRY/YAGNI, naming, file size limits, error handling, testing 80%+ |
| `no-legacy-rule.md` | NUNCA conservar legacy / dead / duplicate / zombie / obsolete code |
| `per-module-claude-md.md` | CLAUDE.md por módulo Apple-style (EN directives + ES comments) |
| `project-detector.md` | Cascada automática al abrir cualquier carpeta (root → top-level → submódulos) |
| `claude-md-freshness.md` | Anti-drift + ADR pattern (Microsoft Azure / AWS / Google) |
| `refs-and-routes-tracking.md` | Auto-update de CLAUDE.md ante cambios estructurales |
| `verification-first.md` | Test pasa O build compila O screenshot antes de "listo" |
| `context-discipline.md` | Two-correction rule, kitchen-sink avoidance |
| `plan-mode-trigger.md` | Cuándo entrar/saltar plan mode |
| `ask-user-question.md` | Interview antes de features grandes |
| `engram-protocol.md` | Memoria persistente cross-session |
| `sdd-orchestrator.md` | Spec-Driven Development workflow |
| `common/*` | Coding style, security, testing, performance, patterns (cross-language) |

### 7 stack overlays (`rules/stack/`)

`typescript.md`, `python.md`, `go.md`, `rust.md`, `java.md`, `swift.md`, `kotlin.md`.

### 4 hooks deterministas (`scripts/`)

| Script | Trigger | Qué hace |
|---|---|---|
| `block-sensitive-files.js` | PreToolUse | Bloquea writes a `.env`, `.pem`, `.key`, `secrets/`, `credentials/` |
| `auto-format.js` | PostToolUse | Auto-format con black/ruff/prettier/gofmt/rustfmt según extensión |
| `detect-structural-change.js` | PostToolUse | Detecta cambios estructurales y avisa actualizar CLAUDE.md |
| `check-claude-md-freshness.js` | Stop | Valida drift de todos los CLAUDE.md antes de cerrar sesión |

### 4 templates de proyectos (`templates/`)

- **small-project**: <20 archivos, MVP, prototipos.
- **medium-project**: 20-200 archivos.
- **large-project**: 200+ archivos. Incluye `docs/adr/` con ADR-0001 inicial, `ARCHITECTURE.md`, `GLOSSARY.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.claude/{settings.json, agents/, skills/, commands/}`.
- **monorepo**: multi-package coordinado.

### Slash commands incluidos en templates

- `/new-adr` — Crea ADR con auto-numbering, actualiza índice y root CLAUDE.md.
- `/audit-freshness` — Audita drift en todos los CLAUDE.md del repo.
- `/refactor-by-layers` — Aplica refactor Hexagonal/Clean.

### Skills incluidas

- `add-module` — Genera módulo con CLAUDE.md + tests skeleton (RED).
- `pre-merge-check` — lint + types + tests + build + security antes de PR.
- `audit-module` — Audita módulo por legacy / dead / drift.

### Agents incluidos

- `code-reviewer` — Review de calidad / seguridad / mantenibilidad.
- `security-auditor` — OWASP Top 10 + secrets + auth flaws.

## Comportamiento que vas a notar

1. **Abrís Claude Code en cualquier carpeta** → audita automático en 2 min, te dice qué hacer.
2. **Tocás un módulo sin CLAUDE.md** → te lo crea Apple-style en mismo commit.
3. **Movés / renombrás archivos** → CLAUDE.md afectados se actualizan solos.
4. **Tomás decisión arquitectónica grande** → genera ADR en `docs/adr/` automático.
5. **Generás código zombie / dead / legacy** → NO lo permite (lo elimina o pregunta).
6. **Intentás escribir un `.env`** → el hook lo BLOQUEA.
7. **Editás un `.py` o `.ts`** → auto-format al guardar.
8. **Cerrás sesión** → check de freshness reporta drift si hay.

## Reglas innegociables compartidas por TODO el equipo

- ❌ Sin código legacy / muerto / duplicado / comentado-out
- ✅ CLAUDE.md por módulo cuando corresponde (Apple-style, EN+ES bilingüe)
- ✅ Verificación obligatoria antes de "listo" (test O build O screenshot)
- ✅ TDD strict: RED → GREEN → IMPROVE
- ✅ 80% coverage mínimo
- ✅ ADR para decisiones grandes (append-only, supersede no edit)
- ✅ Auto-update de CLAUDE.md ante cambios estructurales
- ✅ Hook bloquea archivos sensibles automáticamente

## Actualizar a la última versión

```bash
cd ~/.claude-config && bash UPDATE.sh
```

`UPDATE.sh` hace pull, re-ejecuta install respetando tu `CLAUDE.local.md` (notas personales, gitignored).

## Cómo trata configs ya existentes (v1.1.0+)

| Archivo / carpeta | Comportamiento del installer | Dónde queda lo tuyo |
|---|---|---|
| `~/.claude/CLAUDE.md` | **Marker-based merge**. Replace solo entre `<!-- claude-config:start -->` y `<!-- claude-config:end -->`. | Tu contenido afuera de los markers se preserva en cada update. |
| `~/.claude/settings.json` | **Deep-merge**. Hooks ∪ permissions ∪ plugins ∪ custom keys. | Tus hooks personales conviven con los nuestros. Tus permissions allow/deny se concatenan. Tus keys custom se preservan. |
| `~/.claude/rules/<file>.md` (mismo nombre que el nuestro) | **No-clobber**. Si ya existe con contenido distinto, lo dejamos como está. | El installer reporta los archivos skippeados. Para forzar uno: `cp <repo>/rules/<file> ~/.claude/rules/<file>`. |
| `~/.claude/rules/<custom>.md` (nombre nuevo tuyo) | Preservado | — |
| `~/.claude/scripts/` | Sobreescrito (es tooling, no contenido del usuario) | — |
| `~/.claude/templates/` | No-clobber | Tus templates personalizados quedan. |
| `~/.claude/agents/`, `skills/`, `commands/` | **Intactos** — el installer NO toca estas carpetas | — |
| `~/.claude/plugins/`, `sessions/`, `cache/`, `history.jsonl` | **Intactos** | — |
| `~/.claude/CLAUDE.local.md` | **Preservado siempre**. Si no existe, se crea un scaffold. | Acá va tu identidad personal. Gitignored. |
| `~/.claude/credentials.json` | **Preservado siempre** | — |

Antes de cualquier cambio, el installer hace un backup completo en `~/.claude.backup.<fecha-hora>/`. Si algo sale mal, corré `bash UNINSTALL.sh` para restaurar el último backup.

## Tu config personal

Si querés agregar reglas que solo aplican a vos (no al equipo), creá `~/.claude/CLAUDE.local.md`. El installer NO lo sobrescribe nunca. Tus reglas locales aplican junto con las del equipo.

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

## Soporte

- Issues: github.com/CrisjoSsj/claude-config/issues
- Owner: [@CrisjoSsj](https://github.com/CrisjoSsj)
- Versión actual: 1.0.0

## Licencia

MIT — usalo, copialo, mejorá. Si encontrás algo útil, abrí un PR.
