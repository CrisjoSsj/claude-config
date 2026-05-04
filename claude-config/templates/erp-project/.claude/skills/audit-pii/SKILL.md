---
name: audit-pii
description: Scan a module or whole project for PII leaks, missing classification, missing encryption, missing audit log.
---

Audit code for PII / GDPR / SOX / HIPAA compliance violations.

## Scan patterns

For each Python / TypeScript / Java / Go file, search for:

### Likely PII storage (no classification)
```
email|mail|correo
phone|telefono|cellular|movil
ssn|cuit|dni|tax[_-]?id
passport|license
date[_-]?of[_-]?birth|dob|fecha[_-]?nacimiento
address|direccion|street|city
ip[_-]?address|user[_-]?ip
biometric|fingerprint|face[_-]?id
health|medical|diagnosis|prescription
ethnicity|religion|sexuality
salary|income|compensation
```

For each match, verify:
- Field has `@PII` decorator / `metadata={"pii": ...}` annotation.
- Field has `retention_days` declared.
- Field has `encryption` declared (at_rest required for SSN, payment, health).

### PII in logs
```
logger\.(info|debug|warning|error).*\{.*<pii-field>
print.*<pii-field>
console\.log.*<pii-field>
```

### Card data stored directly
```
credit[_-]?card|card[_-]?number|cc[_-]?num|cvv|cvc|pan
```
→ MUST tokenize via PSP. NEVER store directly.

### Missing audit log on financial mutations
For functions/methods that mutate `Invoice`, `Payment`, `Transaction`, `Account`, `Ledger`:
- Check if `@audited` decorator OR explicit audit log emit exists.
- If not, flag as SOX violation.

### Authorization on PII endpoints
For endpoints returning entities with PII:
- Check `@require_auth` + `@require_permission` + rate limiter.

## Output

```
🛡️ PII / Compliance audit of <scope>:

🚨 CRITICAL (block):
- domain/customer.py:42 — `tax_id: str` stored in plaintext, no encryption
  Fix: encrypt at rest. Add @PII metadata.

- application/billing/charge.py:128 — invoice.status mutation, NO audit log
  SOX violation: financial state change without audit trail
  Fix: @audited(entity="invoice", action="charge")

⚠️ HIGH:
- infrastructure/logger.py:15 — logger.info(f"User {user.email} signed in")
  GDPR Art 5: PII in logs without justification
  Fix: log user.id only, not email

ℹ️ MEDIUM:
- domain/customer.py:78 — `phone` lacks @PII metadata
  Add classification with retention_days, purpose.

📊 Summary:
- Files scanned: 47
- PII fields detected: 23
- Properly classified: 18 (78%)
- Missing classification: 5
- PII in logs: 2
- Missing audit log: 1

¿Aplicar fixes? (sí | revisar primero | no)
```

If user says "sí", apply fixes per item with explicit confirmation per CRITICAL item.

Save audit report to Engram: `project/{name}/audit/pii/{date}`.
