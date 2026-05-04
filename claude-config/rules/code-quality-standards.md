# Code Quality Standards — Always Active

> Comentario en español: regla maestra de código limpio. Aplica a toda IA, todo proyecto.
> Consolida Clean Code (Uncle Bob), best practices oficiales de cada framework, y recomendaciones
> de Anthropic. Usar junto con `common/coding-style.md` y stack overlays.

## 1. Framework / library docs are source of truth

Always consult Context7 MCP or official docs BEFORE coding with a library.

| Library/Framework | Source of truth |
|---|---|
| React | react.dev (Server Components, hooks rules of hooks) |
| Next.js | nextjs.org/docs (App Router conventions, route groups) |
| FastAPI | fastapi.tiangolo.com (DI, Pydantic v2) |
| Django | docs.djangoproject.com (ORM, migrations, admin) |
| TypeScript | typescriptlang.org (strict mode, exhaustive checks) |
| Python | peps.python.org (PEP 8, PEP 484, PEP 695) |
| Go | go.dev/doc (idiomatic Go, error handling) |
| Rust | doc.rust-lang.org (ownership, borrowing, lifetimes) |
| Vue | vuejs.org/guide (Composition API, reactivity) |
| Spring Boot | spring.io/guides (auto-config, profiles) |

NEVER invent APIs. If not 100% sure, fetch the docs via Context7 or WebFetch.

## 2. Naming (mandatory)

- Variables/functions: camelCase (TS/JS) / snake_case (Python/Rust/Go)
- Booleans: prefix `is`/`has`/`should`/`can` (`isLoaded`, `hasPermission`)
- Types/Classes/Interfaces/Components: PascalCase
- Constants: UPPER_SNAKE_CASE
- Custom hooks (React): `use` prefix (`useAuth`)
- Files: match the primary export name (`UserCard.tsx` exports `UserCard`)
- Test files: `<unit>.test.ts` / `test_<unit>.py` / `<unit>_test.go`

## 3. File size limits (HARD)

- Files: <800 lines, target 200-400
- Functions: <50 lines
- Classes: <300 lines (split if violates SRP)
- Cyclomatic complexity: <10 per function
- Nesting depth: ≤4 levels (use early returns)

## 4. SOLID + KISS + DRY + YAGNI

- **Single Responsibility**: 1 file = 1 reason to change
- **Open/Closed**: extend via new types, not modifying existing
- **Liskov Substitution**: subtypes substitutable for base types
- **Interface Segregation**: many small interfaces > one fat
- **Dependency Inversion**: depend on abstractions, not concretions
- **DRY**: 3+ uses of same pattern → extract (rule of three)
- **YAGNI**: don't abstract until 3 real uses
- **KISS**: clarity over cleverness always

## 5. Error handling (mandatory at every layer)

- **Boundaries**: validate ALL external input (API, DB, env vars, file IO)
- Use Result<T, E> patterns (Rust) / discriminated unions (TS) / explicit exceptions (Python)
- NEVER catch and swallow silently
- User-facing errors: friendly message; logs: full stack + context
- NEVER use bare `except:` in Python — use specific exception types
- NEVER use `// @ts-ignore` to silence — fix the type

## 6. Testing (Strict TDD active)

- RED → GREEN → IMPROVE
- Coverage minimum: 80% lines, 70% branches
- Test pyramid: unit > integration > E2E
- Test naming: describe behavior, not implementation
  - ✅ "returns 404 when user doesn't exist"
  - ❌ "test_get_user_function"
- AAA pattern: Arrange, Act, Assert
- One logical assert per test (multiple physical asserts OK if same concept)

## 7. Architectural patterns by stack

- **Backend services with >5 modules**: Hexagonal (Ports + Adapters)
- **Frontend**: feature-based folders, NOT type-based
- **Monorepo**: clear boundaries, no cross-module imports
- **API**: REST resource-oriented OR GraphQL with strict schema
- **State**: server state ≠ client state ≠ URL state ≠ form state
- **Database**: migrations versioned and reversible, schema in repo

## 8. Performance (default budgets)

| Metric | Target |
|---|---|
| LCP | <2.5s |
| INP | <200ms |
| CLS | <0.1 |
| API response p95 | <500ms |
| DB queries | no N+1 (use JOIN or batch) |
| Bundle landing gzip | <150kb |
| Bundle app gzip | <300kb |

Image optimization: AVIF/WebP, explicit dimensions, lazy below-fold.

## 9. Security (non-negotiable)

- NEVER hardcode secrets (API keys, passwords, tokens)
- ALL user input validated at boundary (Pydantic / Zod / class-validator)
- Parameterized queries always (no string concat in SQL)
- HTTPS only in prod, CSP headers, X-Frame-Options DENY
- Rate limit ALL public endpoints
- Auth on every state-changing endpoint
- Secrets via env vars + secret manager, NEVER in repo
- httpOnly + secure cookies for session tokens (NOT localStorage)

## 10. Documentation discipline

- Code comments: ONLY for non-obvious WHY, never WHAT
- Function docstrings: only when public API or complex contract
- README per module if criteria met (per-module-claude-md.md rule)
- ADR for big decisions (claude-md-freshness.md rule)

## 11. Code review checklist (before "listo")

- [ ] Files <800 lines, functions <50 lines
- [ ] No nesting >4 levels
- [ ] All errors handled explicitly
- [ ] No hardcoded secrets / magic numbers
- [ ] Tests added + passing + 80% coverage
- [ ] Names follow conventions
- [ ] No legacy/dead/duplicate code
- [ ] CLAUDE.md updated if structure changed
- [ ] ADR created if decision is "big"
- [ ] Verified: build/test/screenshot

## 12. Stack-specific overlays

@~/.claude/rules/stack/typescript.md
@~/.claude/rules/stack/python.md
@~/.claude/rules/stack/go.md
@~/.claude/rules/stack/rust.md
@~/.claude/rules/stack/java.md
@~/.claude/rules/stack/swift.md
@~/.claude/rules/stack/kotlin.md
