# Python Stack Overlay

> Comentario en español: reglas específicas Python sobre lo común. Aplica cuando el proyecto
> detectado usa Python.

## Version

- Python 3.12+ preferred (PEP 695 type params, `type` statement).
- `pyproject.toml` is the source of truth for deps and config (no `setup.py`).

## Type hints (mandatory on signatures)

- All function signatures fully typed.
- `from __future__ import annotations` at top of every module (PEP 563).
- Use `T | None` instead of `Optional[T]` (PEP 604).
- Use built-in generics: `list[int]`, `dict[str, int]`, NOT `List`, `Dict`.
- `TypedDict` for dict shapes, `Protocol` for structural typing.
- `mypy --strict` or `pyright` in CI.

## Immutability

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class User:
    name: str
    email: str
```

- `frozen=True` always for value objects.
- `slots=True` for memory + speed.
- `kw_only=True` for >3 fields (readability).

## Error handling

- NEVER `except:` bare. Use specific exception types.
- NEVER `except Exception:` without re-raising or logging.
- Custom exception hierarchies for domain errors.
- `raise ... from err` to preserve chain.

## Async

- `asyncio` ecosystem preferred (FastAPI, httpx, aiosqlite).
- `async def` everywhere on the I/O path.
- `asyncio.TaskGroup` (3.11+) for structured concurrency, NOT `gather`.
- NEVER mix sync I/O in async functions (blocks event loop).

## Frameworks

- **FastAPI** for APIs (async-first, Pydantic v2).
- **Django** for full-stack monoliths (ORM, admin, templates).
- **SQLAlchemy 2.0+** with declarative + typed mappings.
- **Pydantic v2** for validation (model_config, ConfigDict).

## Testing

- `pytest` always, NOT unittest.
- `pytest-asyncio` for async tests.
- `pytest-cov` for coverage.
- `factory_boy` or `pytest-fixtures` for test data.
- `httpx.AsyncClient` for FastAPI tests.

## Tooling defaults

- **Formatter**: `black` (line length 100) OR `ruff format`.
- **Linter**: `ruff` (replaces flake8, isort, pyupgrade).
- **Type checker**: `mypy --strict` or `pyright`.
- **Security**: `bandit -r src/`.

## Common pitfalls to avoid

- Mutable default arguments: `def f(x=[]):` → use `None` + create inside.
- `print()` in libraries → use `logging`.
- `os.path` → use `pathlib.Path`.
- Manual JSON parsing → use Pydantic.
- Bare strings as keys → use `Enum` or `Literal`.
- N+1 in ORMs → eager loading (`selectinload`, `joinedload`).
