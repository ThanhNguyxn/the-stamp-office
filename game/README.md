# The Stamp Office - Game

Godot 4.x prototype for **The Stamp Office**.

---

## Status: Shifts 01–10 Playable ✅

All 10 shifts are playable with first-person exploration!

---

## 🎮 Controls

### Two Modes

| Mode | Mouse | Movement | Paper UI |
|------|-------|----------|----------|
| **LOOK** (default) | Captured | WASD works | Cannot click |
| **CURSOR** | Visible | Disabled | Click or use 1-4 keys |

Press **Tab** to toggle modes. Press **E** to focus on desk (enters cursor mode).

### Movement (LOOK Mode)

| Key | Action |
|-----|--------|
| `W`/`A`/`S`/`D` or Arrows | Walk |
| `Shift` | Sprint |
| `Space` | Jump (optional) |
| Mouse | Look around |

### Desk Workflow (CURSOR Mode)

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
| `E` | Focus on desk (work mode) |
| `Esc` | Back to menu |

---

## The Office

Explore the 3D office space:
- Walk around using WASD
- Look around with the mouse
- Press E near the desk to start working
- Press Tab to toggle between exploring and clicking

The desk has a paper UI where you process tickets using the workflow buttons or keyboard shortcuts.

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

---

## Debug HUD

A small green debug overlay shows:
- Current mode (LOOK or CURSOR)
- Position and velocity
- WASD input state

---

## Files

| File | Purpose |
|------|---------|
| `scripts/Player.gd` | First-person movement controller |
| `scripts/Shift.gd` | Gameplay + mouse forwarding |
| `scripts/Office3D.gd` | 3D backdrop + tremor effects |
| `scenes/Office3D.tscn` | Expanded 3D office scene |
| `project.godot` | Input mappings |

---

## Troubleshooting

**WASD doesn't move?**
- Check debug HUD shows "Mode: LOOK"
- Press **Tab** if stuck in CURSOR mode

**Can't click paper?**
- Press **Tab** to enter CURSOR mode
- Or press **E** to focus on desk
