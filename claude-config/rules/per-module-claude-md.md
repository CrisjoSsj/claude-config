# Per-Module CLAUDE.md (Apple-style)

> Comentario en español: cuando creo o refactorizo un módulo, escribo un CLAUDE.md adentro
> siguiendo el patrón Apple. Es la forma de que la IA trabaje sin perderse en proyectos grandes.

## Por qué existe

Claude Code carga los CLAUDE.md descendientes en modo **lazy** — solo se leen cuando tocás un archivo en esa subcarpeta. Eso significa que puedo escribir muchos sin inflar el contexto. Apple escribe uno por módulo (Chat, SAComponents, etc.) y cada uno son 6-9 bullets densos. Anthropic documenta que dividir el CLAUDE.md raíz en archivos por módulo reduce tokens ~80% y mejora la adherencia a las reglas.

## Cuándo crear un CLAUDE.md de módulo (criterios)

Creá uno SI cumple ≥1 de estos:
- El módulo tiene ≥3 archivos de código y una decisión arquitectónica no obvia.
- Hay ≥1 workaround / hack que se justifica con un issue o commit.
- Hay un contrato cross-módulo (este expone X, otro depende de Y).
- Hay un compile-flag, env var o feature flag que cambia el comportamiento.
- Hay una invariante de seguridad / performance / persistencia que el código solo no transmite.
- El módulo es un boundary del hexágono (adapter, port, infra concreto).

NO creés un CLAUDE.md SI:
- La carpeta tiene <3 archivos y nada raro.
- El contenido sería redundante con nombres de archivo / tipos / docstrings.
- Solo querés "documentar para humanos" — para eso está el README.
- El único contenido sería "este módulo contiene X" — eso lo ve la IA con `ls`.

Regla de oro: **un CLAUDE.md que solo dice cosas obvias hace más mal que bien**. Si no hay 5 bullets densos que escribir, no escribas el archivo.

## Estructura obligatoria (Apple-style + bilingüe)

```markdown
# <ModuleName> — <one-line purpose in English>

> Comentario en español: <una línea explicando el módulo y por qué existe>
> Inherits: <relative path to parent CLAUDE.md>

## Architecture decisions
- **<Decision in English>:** <directive in English>.
  <!-- Razón en español: <por qué decidimos esto> -->

## Conventions
- **<Convention in English>:** <directive in English>.
  <!-- Comentario: <contexto en español> -->

## Non-obvious gotchas
- <gotcha in English>
  <!-- Cuidado en español: <explicación> -->

## Workarounds & tickets
- <workaround in English> (issue: <url>)
  <!-- Por qué existe en español: <explicación> -->

## Refs (auto-generated, see refs-and-routes-tracking.md)
**Imports from:** <list>
**Imported by:** <list>
**API routes exposed:** <list>
**Config keys consumed:** <list>
```

Reglas del formato:
- **H1, bullets, directivas en INGLÉS** (la IA los procesa como comandos).
- **Inline HTML comments `<!-- -->` y `> Comentario:` en ESPAÑOL** (para humanos).
- 5-12 bullets típico, 20 hard cap.
- Sin emojis, sin marketing, sin "bienvenido a este módulo".

## Categorías de bullets (qué meter)

| Tipo | Ejemplo |
|---|---|
| **Decision** | "Use AsyncStream, NOT Combine — Combine retain cycles bit prod en v3." |
| **Convention** | "Service providers son `actors`, no `@MainActor`." |
| **Role / Contract** | "Three participant roles: `.client`, `.agent`, `.assistant`." |
| **Compile/Feature flag** | "Heavy `#if JUNO_ENABLED` — chequear xcconfig." |
| **Workaround + ticket** | "Messages wrapped en `MessageGroup` UUID (rdar://164022273). Don't flatten." |
| **Persistence** | "Keychain para `ChatInfo`, file cache en `CachesDirectory/...`." |
| **Bridge entre paradigmas** | "CCChatKit es callback-based; bridged a async/await via Task wrappers." |
| **Performance constraint** | "Bundle gzip <10kb. Si cruza, alerta antes de mergear." |
| **Security invariant** | "PII NUNCA sale de este módulo sin encrypt at rest." |
| **No-go** | "NO importes desde `<otro-módulo>/` — duplicá si lo necesitás." |

## Categorías que NO van en un per-module CLAUDE.md

- Tono / persona / idioma → vive en CLAUDE.md raíz del proyecto.
- Convenciones de commits / git workflow → raíz.
- Reglas globales del usuario (no-legacy, auditoría proactiva) → ya están en raíz, no las repitas.
- "Cómo correr el proyecto" → README.
- Documentación de API pública para humanos → docs/.
- Lo que se ve en el código (nombres, tipos, signatures, imports) → la IA ya lo lee.

## Cuándo generar automáticamente (sin pedir permiso)

**Regla por defecto: si toco un módulo que cumple criterios y NO tiene CLAUDE.md, lo creo. No es opcional, no se pregunta.**

Triggers concretos:

1. **Creo un módulo nuevo** que cumple criterios → genero su CLAUDE.md ANTES de escribir el código.
2. **Refactor parte un monolito** en N módulos → genero N CLAUDE.md.
3. **Toco un módulo existente sin CLAUDE.md** que cumple criterios → lo genero como parte del trabajo.
4. **Agrego un workaround con ticket / compile-flag / decisión no obvia** → lo genero.
5. **Cambio una decisión arquitectónica** en un módulo que ya tiene CLAUDE.md → actualizo el bullet en el mismo commit.

## Auditoría al abrir cualquier módulo

- Cuando abro un archivo, también miro si la carpeta del módulo tiene CLAUDE.md.
- Si NO tiene + cumple criterios → reportar:
  ```
  📝 El módulo <ruta> cumple criterios pero no tiene CLAUDE.md.
     Lo voy a generar como parte de esta tarea.
  ```
  Y lo genero. Sin esperar confirmación salvo "no audites".
- Si tiene + está stale → reportar y actualizar.

Antes de declarar "listo": chequear si los módulos tocados tienen CLAUDE.md o ameritan uno.

## Validación antes de "listo"

- ¿Hay módulos en el cambio que cumplen criterios y no tienen CLAUDE.md? → crearlos.
- ¿Algún CLAUDE.md quedó stale tras este cambio? → actualizar.
- ¿Algún CLAUDE.md tiene >20 bullets, headers internos, o solo describe lo obvio? → reescribir o borrar.
- ¿Cada workaround mencionado tiene un issue / commit linkeado? Si no, el bullet pierde valor.
