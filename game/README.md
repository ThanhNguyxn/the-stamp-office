# The Stamp Office - Game

Godot 4.x prototype for **The Stamp Office**.

---

## Status: Shifts 01–10 Playable ✅

All 10 shifts are playable via the shift selector!

---

## 🎮 Controls

### Two Modes

| Mode | Mouse | Movement | Paper UI |
|------|-------|----------|----------|
| **LOOK** (default) | Captured | WASD works | Cannot click |
| **CURSOR** | Visible | Disabled | Click or use 1-4 keys |

Press **Tab** to toggle modes.

### Movement (LOOK mode)

| Key | Action |
|-----|--------|
| `W`/`A`/`S`/`D` | Walk |
| `Shift` | Sprint |
| Mouse | Look around |

### Workflow (CURSOR mode)

| Key | Action |
|-----|--------|
| `1` | Open folder |
| `2` | Inspect attachment |
| `3` | Check rules |
| `4` | File ticket |
| `R` | Open rulebook |
| `A` | Approve stamp |
| `D` | Deny stamp |

### Other

| Key | Action |
|-----|--------|
| `Tab` | Toggle LOOK/CURSOR mode |
| `E` | Focus/unfocus desk |
| `Esc` | Back to menu |

---

## Run the Prototype

### Step 1: Sync Data

```bash
python tools/sync_game_data.py
```

### Step 2: Run Godot

```bash
godot --path game
```

Or open `game/project.godot` in Godot Editor and press **F5**.

### Step 3: Play

1. Game starts in **LOOK mode** — WASD moves, mouse looks
2. Press **Tab** to switch to **CURSOR mode** — click paper UI
3. Press **Tab** again to return to LOOK mode

---

## Debug HUD

A small debug overlay in the top-left shows:
- Current mode (LOOK or CURSOR)
- Position and velocity
- WASD input state

---

## Files

| File | Purpose |
|------|---------|
| `scripts/PlayerController.gd` | First-person movement + mode toggle |
| `scripts/Shift.gd` | Gameplay + mouse forwarding |
| `scripts/Office3D.gd` | 3D backdrop + tremor |
| `scenes/Office3D.tscn` | 3D scene with Player rig |
| `project.godot` | Input mappings |

---

## Troubleshooting

**WASD doesn't move?**
- Check debug HUD shows "Mode: LOOK"
- Press **Tab** if stuck in CURSOR mode

**Can't click paper?**
- Press **Tab** to enter CURSOR mode
- Mouse should become visible
