# Data Folder

This folder contains structured game data for **The Stamp Office**.

---

## Folder Structure

```
data/
├── README.md           # This file
├── schema.json         # JSON schema definitions
├── tickets/            # Per-shift ticket definitions
│   └── shift01.json    # Tickets for SHIFT_01
├── rules/              # Global and per-shift rules
│   └── rules.json      # All rules indexed by shift
└── toasts/             # System toast messages
    └── toasts.json     # Global toast pool
```

---

## How Data Maps to Shift Scripts

Each `docs/script/SHIFT_XX.md` file describes the narrative flow. The corresponding data files provide machine-readable versions:

| Script Section | Data File | Purpose |
|----------------|-----------|---------|
| Ticket Queue | `tickets/shiftXX.json` | Ticket text, stamps, outcomes |
| Rule Popups | `rules/rules.json` | Rules indexed by `shift` field |
| Toast Pool | `toasts/toasts.json` | Global pool, referenced by ID |

**Relationship:**
- Each ticket's `outcomes.{STAMP}.toast_id` references `toasts.json`
- Rules can have `contradicts[]` to reference conflicting rule IDs
- Tags enable filtering (e.g., `["horror", "kevin"]`)

---

## Rarity Distribution

Toast and ticket rarity follows this distribution:

| Rarity | Weight | Appearance Rate |
|--------|--------|-----------------|
| `common` | 80 | ~80% of occurrences |
| `rare` | 18 | ~18% of occurrences |
| `legendary` | 2 | ~2% of occurrences (gated) |

**Legendary Gating:**  
Legendary items require a `trigger_notes` condition to be met (e.g., "100% approval rate"). They should NOT appear in normal gameplay unless explicitly unlocked via `flags_add[]`.

---

## Meter Fields

Tickets affect two meters via their `outcomes`:

### `mood_delta`
- **Range:** `-3` to `+3`
- **+values:** Player made a "good" choice (subjectively)
- **−values:** Player made an uncomfortable/harsh choice
- **0:** Neutral impact

### `contradiction_delta`
- **Range:** `0` to `+5`
- **+values:** Following rules "correctly" increases this
- **0:** No impact on contradiction
- **Note:** High contradiction = Ending B path

---

## Validation

Run the validator before committing:

```bash
python tools/validate_data.py
```

Checks:
- All `toast_id` references exist in `toasts.json`
- All `text` and `attachment` fields are ≤8 words
- All `id` values are unique within their file

---

## Adding New Shift Data

1. Create `tickets/shiftXX.json` following the schema
2. Add rules to `rules.json` with correct `shift` value
3. Add any new toasts to `toasts.json`
4. Run validator
5. Commit with `data: add shiftXX data`
