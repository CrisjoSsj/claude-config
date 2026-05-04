# Rust Stack Overlay

> Comentario en español: reglas Rust sobre lo común. Aplica cuando el proyecto detectado usa Rust.

## Edition

- Rust 2024 edition preferred (`edition = "2024"` in Cargo.toml).
- `rust-toolchain.toml` pinning the version for reproducibility.

## Ownership & borrowing

- Prefer borrowing (`&T`) over cloning.
- `Cow<'a, T>` for "owned or borrowed" cases.
- `Arc<T>` for shared ownership across threads, `Rc<T>` single-threaded.
- `Mutex<T>` over `RwLock<T>` unless reads >> writes.
- Avoid `unsafe` unless absolutely necessary; document invariants when used.

## Error handling

- `Result<T, E>` everywhere, NOT `panic!` for recoverable errors.
- `thiserror` for library errors (typed).
- `anyhow` for application errors (boxed dyn Error).
- `?` operator for propagation; never `.unwrap()` in production code.
- Custom error enums with `#[derive(thiserror::Error)]`.

## Async

- `tokio` for async runtime (default in ecosystem).
- `async-trait` for traits with async methods (until stabilized).
- Cancellation via `tokio::select!` + cancellation tokens.
- NEVER block in async — use `tokio::task::spawn_blocking` for sync work.

## Testing

- Built-in `#[test]` for unit tests inside modules.
- `tests/` directory for integration tests.
- `proptest` or `quickcheck` for property-based testing.
- `criterion` for benchmarks.
- `cargo test --all-features` in CI.

## Tooling defaults

- `cargo fmt` (mandatory in pre-commit).
- `cargo clippy --all-targets --all-features -- -D warnings`.
- `cargo audit` for vulnerabilities.
- `cargo deny` for license + dep policies.

## Common pitfalls to avoid

- `String` vs `&str` confusion → use `&str` for params, `String` for owned.
- `clone()` everywhere → understand ownership first.
- Lifetime over-annotation → let elision work.
- `Vec<Box<dyn Trait>>` when `Vec<Box<dyn Trait + Send + Sync>>` is needed.
- Forgetting `#[must_use]` on important Result returns.
