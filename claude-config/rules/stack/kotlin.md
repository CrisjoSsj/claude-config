# Kotlin / Android / KMP Stack Overlay

> Comentario en español: reglas Kotlin sobre lo común. Aplica para Android, KMP, server-side Kotlin.

## Version

- Kotlin 2.0+ (K2 compiler).
- Gradle Kotlin DSL (`build.gradle.kts`), NOT Groovy.

## Idiomatic Kotlin

- `val` over `var` always; mutability is opt-in.
- `data class` for value objects.
- `sealed class` / `sealed interface` for ADTs.
- `object` for singletons.
- Extension functions for adding behavior to existing types.
- Top-level functions over utility classes.
- Trailing commas everywhere (better diffs).

## Coroutines

- `suspend` functions on I/O path.
- Structured concurrency: every coroutine has a parent scope.
- `viewModelScope` (Android), `lifecycleScope` for UI.
- `Dispatchers.IO` for blocking I/O, `Dispatchers.Default` for CPU-bound.
- `Flow` for reactive streams; `StateFlow`/`SharedFlow` for state.
- Cancellation cooperative — check `isActive` in long loops.

## Null safety

- NEVER `!!` (force unwrap) in production code.
- `?.let { ... }` for null-safe operations.
- `?:` Elvis operator for defaults.
- Platform types (`String!` from Java) → annotate explicitly with `@Nullable`/`@NotNull`.

## Compose (if Android/multiplatform)

- State hoisting — Composables receive state, emit events.
- `remember` for local state, `rememberSaveable` for config-change survival.
- `LaunchedEffect` for side effects with key.
- `derivedStateOf` for derived state.
- NEVER do business logic inside Composable.

## Architecture

- MVVM with Repository pattern (Android).
- Clean Architecture for KMP (domain/data/presentation modules).
- Use cases (interactors) at the application layer.
- DI via Koin or Hilt.

## Testing

- Kotest preferred over JUnit (more idiomatic).
- MockK for mocks (Mockito has Kotlin issues).
- `runTest` for coroutine tests.
- Turbine for Flow testing.
- Compose UI tests via `ComposeTestRule`.

## Tooling defaults

- ktlint OR detekt for lint.
- Kover for coverage.
- Spotless for formatting.

## Common pitfalls to avoid

- `!!` in production code.
- Blocking calls in coroutines (use `withContext(Dispatchers.IO)`).
- Mutable `data class` — defeats purpose; use immutable + `copy()`.
- Companion objects abused as singletons → use `object`.
- Coroutine launched from non-cooperative scope (memory leak).
