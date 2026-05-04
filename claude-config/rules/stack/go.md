# Go Stack Overlay

> Comentario en español: reglas Go sobre lo común. Aplica cuando el proyecto detectado usa Go.

## Idiomatic Go

- Follow Effective Go and Go Code Review Comments.
- `gofmt` / `goimports` mandatory (auto via hook).
- Short variable names in narrow scope (`i`, `r`), descriptive in wide (`requestCount`).
- Pointer receivers for mutation OR large structs; value receivers otherwise.
- Interfaces small (1-3 methods), defined where consumed.

## Error handling

- Errors are values. Return `error` last in tuple.
- Wrap with `fmt.Errorf("doing X: %w", err)` to preserve chain.
- Sentinel errors: `var ErrNotFound = errors.New("not found")`.
- Custom errors: implement `Error()` + custom fields.
- NEVER use `panic` for control flow — only for unrecoverable.

## Concurrency

- Goroutines need clear lifecycle (context.Context for cancellation).
- Channels: buffered when producer/consumer rates differ.
- `sync.Mutex` for shared state; prefer channel-based design when possible.
- `errgroup.Group` for coordinated goroutines with errors.
- Avoid `select { default: }` busy-loops.

## Testing

- `testing` stdlib + `testify/assert` if needed.
- Table-driven tests: `tests := []struct{...}{...}`.
- Subtests: `t.Run(name, func(t *testing.T){...})`.
- `t.Parallel()` for independent tests.
- `go test -race` in CI.
- Benchmarks: `func BenchmarkX(b *testing.B)`.
- Fuzz tests: `func FuzzX(f *testing.F)`.

## Project layout

- `cmd/<binary>/main.go` for entry points.
- `internal/` for private packages.
- `pkg/` only for explicitly public reusable code.
- `api/` for protobuf / OpenAPI.
- `go.mod` at repo root.

## Tooling defaults

- `goimports` (formats + organizes imports).
- `golangci-lint run` (meta-linter).
- `go vet` and `staticcheck`.
- `govulncheck` for security.

## Common pitfalls to avoid

- Capturing loop variable in closure → use `i := i` shadow before goroutine.
- Comparing errors with `==` → use `errors.Is()`.
- Type assertions without check → `v, ok := x.(T)`.
- Goroutine leaks → always have a way to stop (context).
- `nil` slice vs empty slice in JSON → check before marshal.
