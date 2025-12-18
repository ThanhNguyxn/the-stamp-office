# Data Folder

This folder contains structured game data for **The Stamp Office**.

---

## Folder Structure

```
data/
├── README.md           # This file
├── schema.json         # JSON schema definitions
├── tickets/            # Per-shift ticket definitions
│   ├── shift01.json    # Tickets for SHIFT_01 (12 tickets)
│   ├── shift02.json    # Tickets for SHIFT_02 (14 tickets)
│   ├── shift03.json    # Tickets for SHIFT_03 (13 tickets)
│   ├── shift04.json    # Tickets for SHIFT_04 (12 tickets)
│   ├── shift05.json    # Tickets for SHIFT_05 (13 tickets)
│   ├── shift06.json    # Tickets for SHIFT_06 (12 tickets)
│   ├── shift07.json    # Tickets for SHIFT_07 (12 tickets)
│   ├── shift08.json    # Tickets for SHIFT_08 (14 tickets)
│   ├── shift09.json    # Tickets for SHIFT_09 (14 tickets)
│   └── shift10.json    # Tickets for SHIFT_10 (12 tickets)
├── rules/              # Global and per-shift rules
│   └── rules.json      # All 40 rules (4 per shift)
└── toasts/             # System toast messages
    └── toasts.json     # Global toast pool (119 toasts)
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
- All `id` values are unique **across all ticket files**
- Required keys exist in all data objects
- Per-file PASS/FAIL summary

---

## Adding New Shift Data

1. Create `tickets/shiftXX.json` following the schema
2. Add rules to `rules.json` with correct `shift` value
3. Add any new toasts to `toasts.json`
4. Run validator
5. Commit with `data: add shiftXX data`
