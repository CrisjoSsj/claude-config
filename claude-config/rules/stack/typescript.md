# TypeScript / JavaScript Stack Overlay

> Comentario en español: reglas específicas TS/JS sobre lo común. Aplica cuando el proyecto detectado
> usa TypeScript o JavaScript.

## Strict mode mandatory

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true
  }
}
```

## Module system

- ES modules (`import`/`export`), NOT CommonJS (`require`/`module.exports`).
- Destructure imports when possible: `import { foo } from 'bar'`.
- Named exports preferred over default exports (refactor-friendly).

## Type safety

- NEVER use `any` — use `unknown` and narrow.
- NEVER use `// @ts-ignore` — use `// @ts-expect-error` with reason if absolutely needed.
- Use discriminated unions for state machines, not booleans.
- Use `satisfies` operator for object literals matching a type.
- Use `as const` for tuple/literal inference.

## Async patterns

- `async/await` over `.then()` chains.
- `Promise.all()` for parallel; `Promise.allSettled()` when you need all results.
- Always handle Promise rejection (no floating promises — use ESLint rule).

## React (if applicable)

- Server Components by default in Next.js App Router.
- `'use client'` only when necessary (state, effects, browser APIs).
- Hooks rules: top-level only, never conditional.
- `useState` for client state, TanStack Query for server state.
- NEVER mix data-fetching libraries (pick one).

## Testing

- Vitest preferred over Jest (faster, ESM-first).
- Playwright for E2E.
- Testing Library for component tests (NOT Enzyme).
- MSW for HTTP mocks.

## Tooling defaults

- Bun OR pnpm OR npm — pick one per project.
- Biome OR ESLint+Prettier — pick one per project.
- Type-check in CI: `tsc --noEmit`.

## Common pitfalls to avoid

- `useEffect` for derived state → use `useMemo` or compute inline.
- `useEffect` for event handlers → just inline the handler.
- Stable refs needed → `useCallback` only when passed to memoized children.
- Date math → use date-fns or Temporal, NOT raw `Date`.
- Number formatting → `Intl.NumberFormat`, NOT manual.
