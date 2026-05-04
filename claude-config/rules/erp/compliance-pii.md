# Compliance & PII — GDPR / SOX / HIPAA / PCI-DSS

> Comentario en español: regla de compliance para ERP que maneja datos personales,
> financieros, médicos o de pago. Auditoría automática de PII, audit log mandatorio,
> right-to-be-forgotten, retention rules.

## PII auto-detection (mandatory in any ERP)

PII = Personally Identifiable Information. The IA must detect and flag any code that:

- **Stores PII** without classification: name, email, phone, address, SSN/DNI/CUIT, IP, biometric, financial, medical, ethnicity, sexual orientation, religion.
- **Logs PII** in plaintext (`logger.info(f"User {email}...")`)
- **Exposes PII** via API without authorization check.
- **Persists PII** without retention policy.
- **Transmits PII** without encryption in transit.
- **Stores PII** without encryption at rest (especially: SSN, payment cards, health records).

When detected, the IA reports:
```
🛡️ PII detected at <file:line>:
   Type: <email | phone | ssn | etc>
   Classification: <missing>
   Action required: tag with @PII decorator + add retention policy + ensure auth check.
```

## Data classification (mandatory tags)

Every entity field that holds PII gets classified:

```python
@dataclass
class Customer:
    id: CustomerId
    email: str = field(metadata={"pii": "email", "retention_days": 2555, "purpose": "billing"})
    full_name: str = field(metadata={"pii": "name", "retention_days": 2555})
    tax_id: str = field(metadata={"pii": "tax_id", "encryption": "at_rest", "retention_days": 3650})
    payment_card_last4: str = field(metadata={"pii": "pci", "retention_days": 1095})
    health_notes: str = field(metadata={"pii": "phi", "encryption": "at_rest", "compliance": "HIPAA"})
```

Labels:
- `pii`: type of PII
- `retention_days`: how long to keep (GDPR Art 5(1)(e))
- `encryption`: `at_rest` | `in_transit` | `none` (justify when none)
- `purpose`: legal basis for processing (GDPR Art 6)
- `compliance`: `GDPR | HIPAA | PCI-DSS | SOX`

## Audit log (mandatory for SOX + GDPR)

All state-changing operations on financial / regulated entities emit an audit event:

```python
@audited(entity="invoice", action="approve", reason_required=True)
def approve_invoice(invoice_id, approver_id, reason):
    ...
```

Audit event captures: `who, what, when, where (IP), why (reason), before, after`.

Storage: append-only (NEVER UPDATE/DELETE on audit log table). Sign rows with HMAC for tamper detection.

## Right to be forgotten (GDPR Art 17)

Every PII-bearing aggregate must implement:

```python
class Customer(Aggregate):
    def anonymize(self):
        """Replace PII fields with deterministic hashes. Keep ID for legal records."""
        self.full_name = f"REDACTED-{hash(self.id)}"
        self.email = f"deleted+{self.id}@anonymized.local"
        self.phone = None
        # Keep transaction history (legal retention) but unlink personal data
```

Rules:
- NEVER hard-delete records that have legal retention requirements (invoices, audit logs).
- Anonymize PII while preserving aggregate structure.
- Log the anonymization in the audit log itself.
- Provide endpoint: `DELETE /v1/customers/<id>/personal-data` returns 202 Accepted + async job.

## Retention enforcement

Cron job runs daily:

```python
def enforce_retention():
    for entity in entities_with_retention():
        for record in entity.find_expired():
            record.anonymize_or_delete()
            audit_log("retention_enforced", record.id)
```

## Encryption requirements

| Data type | At rest | In transit | Hashing |
|---|---|---|---|
| Passwords | bcrypt/argon2 | TLS | NEVER plaintext |
| Payment cards (PCI) | AES-256 + HSM | TLS 1.2+ | tokenize via PSP |
| Health records (PHI) | AES-256 | TLS 1.2+ | n/a |
| SSN / Tax ID | AES-256 | TLS 1.2+ | n/a |
| Email / phone | optional but recommended | TLS | n/a |

NEVER:
- Store payment cards directly. Tokenize via Stripe/Adyen/etc.
- Use MD5 / SHA1 for passwords. Use bcrypt/argon2id with cost ≥12.
- Decrypt PII to log files for debugging.

## Authorization on every PII endpoint

Every endpoint returning PII requires:
- Authenticated user.
- Authorization check (the user has permission to see THIS specific record).
- Rate limiting (prevent enumeration).
- Audit log entry (who accessed what).

```python
@require_auth
@require_permission("customer:read")
@rate_limit("100/min")
@audited(action="read", entity="customer")
def get_customer(customer_id):
    if not current_user.can_access_customer(customer_id):
        raise Forbidden()
    return CustomerDTO.from_domain(repo.get(customer_id))
```

## Compliance ADR template

When a compliance-relevant decision is made, generate an ADR with extra fields:

```markdown
## Compliance impact
- Regulations affected: GDPR Art X, SOX Section Y
- DPO/Legal review: required | not required
- Audit trail changes: yes/no
- Data subject rights affected: access | erasure | portability | rectification
```

## Anti-patterns

- ❌ Storing tax IDs / SSNs in plaintext.
- ❌ Logging emails or phone numbers in INFO level.
- ❌ Exposing PII via search endpoints without rate limiting.
- ❌ Using soft-delete (just a `deleted_at` flag) for PII — that's not GDPR compliant.
- ❌ Mixing test/dev/staging databases with prod PII.
- ❌ Letting devs query prod for "debugging" without audit log.
- ❌ Storing payment card details directly (always tokenize).
