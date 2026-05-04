# Verification-First — single highest-leverage rule

> Comentario en español: Anthropic documenta que la verificación es "the single highest-leverage thing".
> NUNCA declarar trabajo completo sin evidencia objetiva. Esta regla es no negociable.

## Mandatory before declaring "listo" / "done"

NEVER declare work complete without ONE of these:

- **Test that passes** — real test runner output, not "I thought through the test mentally".
- **Build that compiles** — `npm run build`, `cargo build`, `tsc --noEmit`, `pytest`, `go build`, etc.
- **Screenshot compared** — for UI changes, capture before/after and list differences.
- **Output validated** — for CLI/scripts, execute and compare against expected example.

## Concrete rules

- If user requested a bug fix → write a test that reproduces the bug BEFORE fixing it. If fix works, test goes RED → GREEN.
- If change is UI → screenshot via preview tools or Playwright. NEVER "looks good in code".
- If you cannot verify (no tests, can't run server) → STATE IT EXPLICITLY: "I couldn't verify X, please confirm manually". Never assume.
- **Address root causes, not symptoms.** If build fails with error X, fix the cause; never silence with `try/except: pass` or `// @ts-ignore`.
- If `claude --permission-mode plan` was used to plan, verify implementation matches the plan after coding.

## Why this matters

> "Without clear success criteria, Claude might produce something that looks right but actually doesn't work. You become the only feedback loop, and every mistake requires your attention." — Anthropic best practices

## Verification ladder (use the strongest available)

1. **Strongest**: full test suite passing + integration test + screenshot
2. **Strong**: unit test passing + manual smoke check
3. **Medium**: build compiles + import smoke (`python -c "import module"`)
4. **Weak**: lint passes + type check passes
5. **Useless**: "looks correct to me"

If you only have weak verification, SAY SO. Don't dress it up as strong.

## Anti-pattern: trust-then-verify gap

Symptom: produced code that "looks plausible" but has unhandled edge cases.
Fix: ALWAYS provide verification (tests, scripts, screenshots). If you can't verify, don't ship.
