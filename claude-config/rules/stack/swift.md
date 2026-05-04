# Swift / iOS-macOS Stack Overlay

> Comentario en español: reglas Swift sobre lo común. Aplica para iOS, macOS, visionOS, watchOS.

## Version

- Swift 6 with strict concurrency checking.
- Xcode latest stable.

## Concurrency (Swift 6)

- `async`/`await` everywhere on I/O path.
- `actor` for shared mutable state across tasks.
- `@MainActor` on UI-touching types and methods.
- `Sendable` conformance for cross-actor types.
- `AsyncStream`/`AsyncSequence` for reactive data, NOT Combine (deprecated path).
- `TaskGroup` for structured concurrency.

## SwiftUI

- `@Observable` (Swift 5.9+) for view models, NOT `ObservableObject`.
- `@State` for local view state, `@Bindable` for bindings.
- View extraction: small Views with computed properties.
- NEVER side effects in `body` — use `.task` / `.onAppear` / `.onChange`.
- Use `NavigationStack` (NOT deprecated `NavigationView`).

## UIKit (legacy)

- Auto Layout via constraints in code OR Storyboards (pick one).
- `UIContentConfiguration` for cell content (NOT custom subclasses).
- Diffable data sources for collections.

## Persistence

- SwiftData (modern) OR Core Data (legacy) for structured data.
- Keychain for secrets, NEVER UserDefaults for sensitive data.
- File cache in `URL.cachesDirectory` for transient data.

## Testing

- Swift Testing (Swift 6) preferred over XCTest.
- `@Test` macro with descriptive names.
- `#expect()` for assertions.
- UI tests via XCUITest.

## Tooling defaults

- SwiftLint with strict config.
- SwiftFormat in pre-commit.
- `swift package resolve` deterministic builds.

## Platform variants

- `#if os(visionOS)`, `#if os(macOS)` for platform-specific code.
- iOS version conditionals: `#available(iOS 17, *)`.

## Common pitfalls to avoid

- Force unwrapping (`!`) in production code — use `guard let` / `if let`.
- Implicitly unwrapped optionals (`String!`) — declare proper optional.
- `weak self` missing in closures that escape → retain cycle.
- `DispatchQueue.main.async` in SwiftUI → use `@MainActor`.
- Sync I/O on main thread → `async`/`await`.
