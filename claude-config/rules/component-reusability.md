# Component & Module Reusability — Composition Patterns

> Comentario en español: regla universal sobre componentes y módulos reutilizables.
> Aplica a frontend (React/Vue/Svelte/Solid/Angular), backend (módulos, services, libs)
> y cualquier sistema donde la composición valga oro. Language-agnostic.

## Core principle: composition over duplication, but only after rule-of-three

- **Don't extract too early.** Three concrete uses → extract. Two uses → wait. One use → never.
- **Don't extract too late.** When duplication makes a bug fix require N edits in N places, you're already in debt.

The line between "premature abstraction" (YAGNI violation) and "missing abstraction" (DRY violation) is **the rule of three**.

## Frontend components (React-style, applies to Vue/Svelte/Solid/Angular)

### Component hierarchy (Atomic Design)

| Level | Examples | Reusability | State |
|---|---|---|---|
| **Atoms** | Button, Input, Label, Icon, Badge | maximum (use everywhere) | usually stateless |
| **Molecules** | SearchBar (Input + Button), FormField (Label + Input + Error) | high | usually stateless |
| **Organisms** | Header (Logo + Nav + UserMenu), DataTable, ProductCard | medium | maybe stateful |
| **Templates** | DashboardLayout, AuthLayout, AdminShell | medium | layout-only |
| **Pages / Screens** | DashboardPage, LoginPage | one place | data-fetching, routing |

Rules:
- **Atoms NEVER fetch data.** They receive props.
- **Molecules NEVER fetch data.** They receive props.
- **Organisms MAY fetch data** via hooks/composables but expose props for testing.
- **Pages own data.** They compose organisms + pass props down.

### Component design rules

1. **Single responsibility.** A component does ONE thing. If it does two, split.
2. **Props are the API.** Every prop is documented. Avoid prop bloat (>10 props = split).
3. **Children > config.** Prefer `<Card><CardHeader/><CardBody/></Card>` over `<Card header={...} body={...}/>`. More flexible.
4. **Composition > inheritance.** Never extend components via class inheritance. Use composition.
5. **Headless first, presentational second.** Build behavior + ARIA in a headless component (state + events + accessibility), wrap with styled presentational variants. Examples: Radix UI, Headless UI, react-aria.
6. **Controlled vs uncontrolled.** Default to controlled (parent owns state). Provide uncontrolled variant if it simplifies common cases (`defaultValue` prop).
7. **Forwarded refs.** When wrapping a primitive (`<button>`, `<input>`), forward `ref` so consumers can use it.
8. **Polymorphic via `as` prop.** `<Button as="a" href="...">` — render as different element without copy-paste.

### Compound components pattern

For UIs with related parts sharing state:

```jsx
<Tabs defaultValue="overview">
  <Tabs.List>
    <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
    <Tabs.Trigger value="settings">Settings</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="overview">...</Tabs.Content>
  <Tabs.Content value="settings">...</Tabs.Content>
</Tabs>
```

Parent owns state, children consume via context. Beats prop-drilling for complex widgets.

### Render props / slots

When behavior is shared but markup must vary:

```jsx
<DataLoader url="/api/products">
  {({ data, loading, error }) =>
    loading ? <Spinner/> : <ProductGrid items={data}/>
  }
</DataLoader>
```

Vue/Svelte equivalent: `<slot>` with scoped props.

### Container/Presentational split

- **Container**: data loading, side effects, mutations.
- **Presentational**: receive props, render UI, emit events. Pure.

```
<UserListContainer>           ← fetches users, manages state
  <UserList users={users}      ← pure: renders
    onSelect={...} />
</UserListContainer>
```

Presentational components are easy to test (no I/O), reuse (any data source), and storybook (just pass mock props).

### Component catalog (Storybook / Histoire / Ladle)

Mandatory for any UI library / shared components folder. Each component has:
- A `Default` story (typical usage).
- Stories for every meaningful state (loading, empty, error, full).
- Stories for edge cases (very long text, RTL languages, narrow viewport).
- A11y addon enabled to detect issues at build time.

### Naming conventions

- Components: PascalCase (`UserCard.tsx` exports `UserCard`).
- Hooks/composables: `use` prefix (`useAuth`, `useDebounce`).
- Higher-order components: `with` prefix (`withAuth(Page)`).
- Render-props children: descriptive function name (not anonymous).
- File names match the primary export.

### Anti-patterns (frontend)

- ❌ Components with 15+ props (split into smaller).
- ❌ "God component" doing data + business logic + UI.
- ❌ Conditional rendering deeper than 2 levels (extract sub-components).
- ❌ Prop drilling 3+ levels (use context or compound components).
- ❌ Class inheritance between components.
- ❌ Inline arrow functions as props on hot lists (re-render churn).
- ❌ Side effects in render (move to effects/lifecycle).
- ❌ Components that read AND mutate global state (separate read-only from mutation).
- ❌ Storybook stories that are just "looks fine" without interaction tests.

## Backend modules / services (the same principles, different shape)

### Module design rules

1. **Single responsibility per module.** One module = one cohesive concept (auth, billing, notifications, etc.).
2. **Stable public API.** Each module exposes a small, intentional surface. Internal types are NOT exported.
3. **Dependency injection.** Modules receive dependencies (DB session, logger, config) — they don't reach for globals.
4. **No circular dependencies.** Module A → B → C → A is a smell. Refactor or break the cycle with events.
5. **Hexagonal layering inside the module.** Domain (pure) → Application (use cases) → Infrastructure (adapters). Domain does NOT import from Application or Infrastructure.

### Service composition patterns

- **Pipeline / chain of responsibility**: chained handlers process a request. Easy to insert/remove steps.
- **Strategy pattern**: pluggable algorithm chosen at runtime (`PaymentStrategy.process()` with Stripe/Adyen/PayPal implementations).
- **Decorator pattern**: wrap a service to add cross-cutting concerns (logging, retries, caching).
- **Factory pattern**: create complex objects via a single creation point (centralizes invariants).
- **Repository pattern**: abstract data access so business logic doesn't know SQL.

### Library / package design

If extracting a module to a shared library:

- **Bounded API surface.** Export only what consumers need. `__all__` (Python) / barrel `index.ts` curated.
- **Semver discipline.** Major bump for breaking change. Minor for additive. Patch for bug fix.
- **Zero internal coupling.** Library doesn't reach into consumer's data — consumer passes everything in.
- **Configurable, not opinionated.** Library accepts config. Doesn't assume framework, logger, DB.
- **Dependency-light.** Few transitive deps. No bringing in 200MB of `lodash` for one helper.

### Anti-patterns (backend)

- ❌ Module that imports from 10+ other internal modules (shotgun coupling).
- ❌ "Util" module that grows to 5000 lines (split by concern).
- ❌ Service that reads from one module's DB and writes to another module's DB directly.
- ❌ Public function with 15 parameters (group into config object or split).
- ❌ Hidden dependencies (function reads env var inside, instead of receiving it).
- ❌ Inheritance hierarchy 4+ deep (favor composition + protocols/interfaces).
- ❌ Cross-module imports of internal types (use ACL / DTO / event payload).

## Cross-cutting: views in any framework

A "view" is the visible/exposed unit. Frontend views = React/Vue components. Backend views = templates (Jinja, ERB, Razor) + serialized API responses.

Same principles apply:
- **Reusable views** are presentational, take data as props/locals, no I/O.
- **Page-level views** are containers — they fetch data and pass to reusable views.
- **DRY but with rule of three** — extract a partial template only after 3 uses.
- **Catalog them** — Storybook for components, sample renderings for templates.

## Reusability checklist (mandatory before merging shared components)

- [ ] Single responsibility documented in CLAUDE.md or component docstring.
- [ ] Public API minimal and stable (props, events, slots).
- [ ] Tested in isolation (no I/O, no global state mocks).
- [ ] At least one Storybook story (UI) or example call (backend).
- [ ] No hidden global access (state, env, time, randomness via dep injection).
- [ ] Accessible by default (a11y for UI; clear errors for backend).
- [ ] Documented breaking-change policy (semver + CHANGELOG).
- [ ] Performance characteristics declared (re-render cost, time complexity).

## CLAUDE.md per shared-components module (mandatory)

Add this section to the component library's CLAUDE.md:

```markdown
## Reusable components

**Component hierarchy**: atomic design (atoms → molecules → organisms → templates → pages)

**Public API surface**:
- atoms/: Button, Input, Icon, Badge, Tooltip
- molecules/: SearchBar, FormField, Toast
- organisms/: DataTable, Modal, Sidebar

**Catalog**: Storybook at /storybook (CI fails if a11y issues found)

**Versioning**: semver. Breaking changes documented in CHANGELOG.md.

**Patterns used**:
- Compound components for Tabs, Accordion, Dialog
- Render props for DataLoader, AsyncBoundary
- Headless + styled split via Radix UI primitives

**Reusability rules**:
- Atoms NEVER fetch data
- Headless logic separate from styled presentation
- Theme via design tokens (CSS variables)
- All interactive components support keyboard nav + screen reader
```
