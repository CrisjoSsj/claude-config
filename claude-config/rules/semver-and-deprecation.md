# Semantic Versioning & Deprecation Policy

> Comentario en español: cómo versionar releases y cómo deprecar APIs sin romper consumidores.
> Aplica a librerías, servicios con clientes externos, paquetes internos compartidos.

## Semver (mandatory for any shared/published package)

`MAJOR.MINOR.PATCH` per https://semver.org/

| Bump | When | Examples |
|---|---|---|
| **MAJOR** | Breaking change to public API | Removed function, changed signature, renamed export, type narrowed |
| **MINOR** | Backwards-compatible additive change | New function, new optional param, new type alias, new component |
| **PATCH** | Backwards-compatible bug fix | Fixed null pointer, corrected calculation, doc fix |

Pre-1.0 (`0.x.y`): MINOR can break. After 1.0, breaking only via MAJOR.

## What counts as "public API"

- Exported functions, classes, types, components.
- Documented configuration options (env vars, settings keys).
- HTTP endpoints + request/response schemas.
- Database schema (for libraries that own a schema).
- Event payload structures.
- CLI flags + output format.

What is NOT public API:
- Internal modules (Python `_private`, TypeScript files outside the barrel).
- Test fixtures, mocks, dev tooling.
- Implementation details (ORM-specific behavior, internal caching).

## Breaking change checklist (before bumping MAJOR)

- [ ] CHANGELOG.md describes the breaking change with migration steps.
- [ ] Deprecation warning was emitted in the previous MINOR release (≥30 days ago for libraries with consumers).
- [ ] Migration guide written (`docs/migration/v2.md` or similar).
- [ ] Codemod available if change is mechanical (jscodeshift, libcst).
- [ ] Affected consumers notified (Slack/email/issue tag).
- [ ] Old version branch maintained with security fixes for N months.

## Deprecation policy

Deprecating a public API takes ≥2 release cycles:

### Cycle 1: announce (MINOR release)

```python
import warnings

def old_function(x):
    warnings.warn(
        "old_function is deprecated, use new_function. Will be removed in v3.0.",
        DeprecationWarning,
        stacklevel=2,
    )
    return new_function(x)
```

```typescript
/**
 * @deprecated Use newFunction. Will be removed in v3.0.
 */
export function oldFunction(x: T): U {
  console.warn("oldFunction is deprecated, use newFunction. Removed in v3.0.");
  return newFunction(x);
}
```

CHANGELOG entry: "Deprecated `old_function` (will be removed in v3.0). Use `new_function`."

### Cycle 2: remove (MAJOR release)

CHANGELOG entry: "**BREAKING:** Removed `old_function` (deprecated since v2.3.0). Use `new_function`."

### Minimum deprecation window

| Type of consumer | Min window |
|---|---|
| Internal team only (your repo) | 1 release |
| Internal company-wide | 1 month |
| External public users | 6 months OR 2 major releases (whichever longer) |
| Critical infrastructure | 12 months |

## CHANGELOG.md format (mandatory)

Per https://keepachangelog.com/

```markdown
## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [2.4.0] — 2026-05-15

### Added
- New `searchByTag` function in queries module.
- TypeScript declarations for `dataLoader`.

### Deprecated
- `oldFunction(x)` — use `newFunction(x, options)` instead. Will be removed in v3.0.

### Fixed
- `paginate()` returned wrong total count for empty result sets.
```

## Communication channels for breaking changes

- Tag releases in git (`git tag v2.4.0`).
- Publish CHANGELOG on release page.
- Pin CHANGELOG entry in repo README under "Breaking changes notice" until next minor.
- For services: send notice to API consumers ≥30 days before sunset.

## Anti-patterns

- ❌ Bumping MAJOR for every change (consumers can't keep up).
- ❌ Bumping PATCH for breaking change (silent break).
- ❌ Removing without deprecation cycle.
- ❌ Deprecation warning without removal target version.
- ❌ Vague CHANGELOG entries ("misc fixes", "various improvements").
- ❌ No migration guide for breaking changes.
- ❌ Multiple breaking changes in same MAJOR without grouping in migration doc.
