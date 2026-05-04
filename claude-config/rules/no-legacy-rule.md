# Regla Absoluta — No Legacy / Dead / Duplicate Code

> Comentario en español: NUNCA conservar, generar ni duplicar código legacy, muerto, comentado-out
> o sin uso vivo. SIEMPRE eliminar. Aplica a TODOS los proyectos del usuario, todas las sesiones,
> todos los lenguajes. No negociable salvo autorización explícita en la sesión.

## Qué eliminar AUTOMÁTICAMENTE (sin pedir permiso) — solo en lo que YO genero o toco

- Archivos sin call-sites vivos → `git rm`. Nunca renombrar a `_legacy_*`, `_old_*`, `_deprecated_*`, `_archived_*`, `*.bak`, `*.copy.*`, `*_v2.*`, `*_new.*`, `*_backup.*`. Git ya conserva la historia.
- Funciones, clases, métodos, variables, imports sin referencias → eliminar.
- Bloques `if False:`, código comentado de >5 líneas, `# TODO: borrar`, `# DEPRECATED`, `# UNUSED` → eliminar.
- Duplicados detectables dentro del mismo módulo / proyecto → consolidar en uno y borrar el otro.
- Shims de back-compat sin callers vivos reales → eliminar.
- Stubs / placeholders / `raise NotImplementedError` "para después" → no generar.

## Qué NO generar nunca

- Funciones placeholder, archivos `_legacy_*` "por las dudas", doble implementación "vieja + nueva" conviviendo.
- Si reemplazás algo, reemplazalo de una. No dejes la versión vieja al lado.

## Excepciones

- ÚNICA excepción al borrado automático: el usuario dice explícitamente en la sesión "dejalo por ahora", "lo veo después", "no borres aún".
- Entre proyectos del mismo monorepo donde la regla del CLAUDE.md raíz permite duplicar con conciencia, la duplicación CRUZADA es válida; la duplicación INTERNA dentro de un mismo modo NO.

## Checklist pre-"listo" (obligatorio)

Antes de declarar un refactor o feature como completo, grep en lo modificado:
- `_legacy`, `_deprecated`, `_old`, `_bak`, `_archived` → debe estar vacío.
- `# TODO: (borrar|delete|remove)` → debe estar vacío.
- `if False:`, `# noqa: dead`, código grande comentado → debe estar vacío.
- Funciones/clases sin call-sites en grep del repo → eliminar.

## Auditoría proactiva de código preexistente (OBLIGATORIO)

Cada vez que abro un archivo / módulo / carpeta para una tarea, debo escanearlo en busca de basura preexistente y REPORTARLA al usuario aunque no sea parte de lo que me pidió:

- Archivos `_legacy_*`, `_old_*`, `_archived/`, `*.bak`, `*.copy.*`, `*_v2.py`, `*_new.py`, `*_backup.*`.
- Funciones / clases / métodos / variables / imports sin call-sites en grep del repo.
- Bloques de código comentado de >5 líneas, `if False:`, `# DEPRECATED`, `# UNUSED`.
- Duplicados detectables (mismo nombre y/o cuerpo idéntico en dos archivos).
- Archivos zombie: dependencias rotas, imports a módulos que no existen, código que crashea si se importa.
- TODOs / FIXMEs viejos sin contexto.

**Formato del reporte:**
```
🧟 Basura detectada en <ruta>:
  - <tipo>: <archivo:línea> — <descripción 1 línea>
¿Borro / consolido / dejo? (borrar | consolidar | dejar | dejar-todo)
```

NO borro sin confirmación cuando se trata de código PREEXISTENTE no relacionado con la tarea actual. SÍ borro automáticamente lo que YO genero o toco en la tarea actual (esa es la regla de arriba).

**Excepción única a toda esta sección:** el usuario dice "no audites", "dejá lo que ya está", "no me reportes basura ahora".
