# i18n — Money, Time, Locale

> Comentario en español: en ERP, los errores de moneda, redondeo y zona horaria
> generan pérdidas financieras reales. Esta regla obliga tipos seguros y patrones
> probados.

## Money (NEVER use float)

Mandatory: every monetary value is a `Money(amount, currency)` value object backed by `Decimal`. NEVER `float`.

```python
from decimal import Decimal
from dataclasses import dataclass

@dataclass(frozen=True)
class Money:
    amount: Decimal      # NEVER float
    currency: str        # ISO 4217 code: USD, EUR, ARS, etc.

    def __add__(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise CurrencyMismatch(self.currency, other.currency)
        return Money(self.amount + other.amount, self.currency)

    def __mul__(self, factor) -> "Money":
        # Factor must be Decimal or int, never float
        if isinstance(factor, float):
            raise TypeError("Multiplying Money by float is forbidden — use Decimal")
        return Money(self.amount * Decimal(str(factor)), self.currency)
```

## Currency arithmetic rules

- **Same-currency arithmetic only.** Add/subtract/compare always check currency. Mismatch → exception.
- **Cross-currency operations** require explicit conversion through `ExchangeRateService.convert(amount, from_ccy, to_ccy, rate_date)`. Rate is recorded as evidence.
- **Rounding** uses `Decimal.quantize(Decimal('0.01'), rounding=ROUND_HALF_EVEN)` (banker's rounding), unless local jurisdiction requires otherwise.
- **Allocation** (splitting a total across N items) uses Martin Fowler's allocation algorithm to avoid rounding leftovers.
- **Tax** computation: round at the line item level, then sum. NEVER sum then round.

## Storage in DB

Money is stored as TWO columns: `amount` (DECIMAL with explicit scale) + `currency` (CHAR(3)).

```sql
CREATE TABLE invoice_lines (
    id UUID PRIMARY KEY,
    amount DECIMAL(19, 4) NOT NULL,    -- 4 decimals to handle FX
    currency CHAR(3) NOT NULL,
    ...
);
```

NEVER store as a single string `"100.00 USD"` (unparseable, can't index).
NEVER store as cents-only INTEGER without explicit scale (jpy = 0 decimals, btc = 8 decimals, varies per currency).

## Time / Timezone (UTC at boundaries)

Mandatory:
- **Storage**: ALL timestamps in UTC (`TIMESTAMP WITH TIME ZONE` or store epoch + offset).
- **API I/O**: ISO 8601 with explicit offset (`2026-05-04T14:30:00-05:00` or `Z`).
- **Domain logic**: timezone-aware datetime always. NEVER naive datetimes in business code.
- **Display layer**: convert to user's locale timezone at the very last moment.

```python
# WRONG
created_at = datetime.now()  # naive, system-local TZ
if created_at.date() == today():  # ambiguous

# RIGHT
from datetime import datetime, timezone
created_at = datetime.now(timezone.utc)
user_tz = current_user.timezone  # "America/Argentina/Buenos_Aires"
local = created_at.astimezone(ZoneInfo(user_tz))
if local.date() == today_in_tz(user_tz):
```

## Date-only fiscal logic

Periods, due dates, fiscal years use `date` (not `datetime`). But beware:
- "End of month" depends on locale calendar (Hebrew, Hijri, etc. — for ERP serving those markets).
- "Business day" depends on country holidays. Use `holidays` library + per-country config.
- Tax periods are jurisdiction-specific (Argentina: monthly + annual; US: quarterly federal + state varies).

## Locale (language + region + format)

Locale is composed: `<language>-<region>` (e.g. `es-AR`, `en-US`, `pt-BR`).

- **Number formatting**: `Intl.NumberFormat` (JS) / `babel.numbers.format_decimal` (Python). NEVER manual.
- **Date formatting**: `Intl.DateTimeFormat` / `babel.dates.format_date`.
- **Currency display**: locale-aware (`USD 1,234.56` in en-US vs `1.234,56 USD` in de-DE).
- **Pluralization**: ICU MessageFormat or equivalent. NEVER `f"{n} item{'s' if n != 1 else ''}"` — that breaks in es/ru/ar.
- **Sort order**: collation-aware (Spanish: ñ between n and o; German: ä = a in DIN 5007-1).

## Multi-currency reporting

ERP reports often need values in a "reporting currency":

```python
# Each transaction has its native currency + reporting equivalent at FX rate of the day.
@dataclass(frozen=True)
class Transaction:
    native_amount: Money         # USD 100
    reporting_amount: Money      # ARS 100000 at rate of trade_date
    rate: Decimal                # 1000.0
    rate_date: date              # FX rate date used
```

Reports aggregate in `reporting_amount`. NEVER convert at report-time using current rate (that's reconciliation hell).

## CLAUDE.md per bounded context

```markdown
## i18n
- **Currencies supported**: USD, EUR, ARS, BRL, MXN
- **Reporting currency**: USD (per ADR-0008)
- **Timezone storage**: UTC always
- **Number/date format**: locale-aware via `babel`
- **Currency rounding**: ROUND_HALF_EVEN per IFRS, override for jurisdictions requiring HALF_UP
```

## Anti-patterns

- ❌ `total = price * quantity` where price is float.
- ❌ `if currency == "USD"` hardcoded — use the field, all currencies are valid.
- ❌ `datetime.now()` (naive) anywhere in business code.
- ❌ Converting at report time using current FX rate.
- ❌ `f"{amount:,.2f}"` for display — not locale-aware.
- ❌ Storing `created_at` as INTEGER unix epoch without TZ context.
- ❌ Assuming month is 30 days, year 365 (leap, fiscal vs calendar).
- ❌ Pluralization via `+ "s"`.
