# Tools

Development utilities for **The Stamp Office**.

---

## Data Validator

Validates game data files for consistency and correctness.

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
| Unique IDs | No duplicate IDs within files |
| JSON validity | Files parse correctly |

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All checks passed ✓ |
| `1` | One or more checks failed ✗ |

### Example Output

```
==================================================
The Stamp Office - Data Validator
==================================================

Loading toasts.json...
  Found 28 toast IDs
Loading rules.json...
  Found 8 rules
Loading shift01.json...
  Found 12 tickets

==================================================
PASS - All checks passed!
==================================================
```

---

## Adding New Tools

1. Create your script in `tools/`
2. Add documentation to this README
3. Commit with `tools: add [tool name]`
