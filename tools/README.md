# Tools

Development utilities for **The Stamp Office**.

---

## Data Validator

Validates game data files for consistency and correctness. Scans all `shift*.json` files in `data/tickets/`.

### Usage

```bash
# From repo root
python tools/validate_data.py
```

### What It Checks

| Check | Description |
|-------|-------------|
| Toast references | All `toast_id` values exist in `toasts.json` |
| Word counts | Text and attachment fields are ≤8 words |
| Unique IDs | No duplicate IDs across all shift files |
| Required keys | All data objects have required fields |
| JSON validity | Files parse correctly |

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All checks passed ✓ |
| `1` | One or more checks failed ✗ |

### Example Output

```
============================================================
The Stamp Office - Data Validator
============================================================

Loading toasts.json...
  Found 119 toast IDs
Loading rules.json...
  Found 40 rules
Loading shift01.json...
  Found 12 tickets
Loading shift02.json...
  Found 14 tickets
...
Loading shift10.json...
  Found 12 tickets

------------------------------------------------------------
Per-File Summary:
------------------------------------------------------------
  ✓ toasts.json: PASS
  ✓ rules.json: PASS
  ✓ shift01.json: PASS
  ...
  ✓ shift10.json: PASS

============================================================
PASS - All checks passed!
============================================================
```

---

## Adding New Tools

1. Create your script in `tools/`
2. Add documentation to this README
3. Commit with `tools: add [tool name]`
