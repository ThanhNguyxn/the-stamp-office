# The Stamp Office - Game

Godot 4.x prototype for **The Stamp Office**.

---

## Status: Shifts 01–10 Playable ✅

All 10 shifts are playable via the shift selector!

---

## 🎮 Controls

This is a **desk workflow game** — there is no WASD movement by design. You sit at your desk and process paperwork.

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `1` | Open folder |
| `2` | Inspect attachment |
| `3` | Check rules (opens rulebook) |
| `4` | File ticket |
| `R` | Open rulebook |
| `A` | Approve (when stamps visible) |
| `D` | Deny (when stamps visible) |
| `H` | Hold (when available) |
| `F` | Forward (when available) |
| `Space`/`Enter` | Close rulebook |
| `Esc` | Close popup / Back to menu |

### Interrupt Events

When an event popup appears:
- Press `A` or `1` for first choice
- Press `B` or `2` for second choice

### Mouse Controls

Click directly on the 3D paper to interact with buttons. The paper displays the workflow UI.

---

## Run the Prototype

### Step 1: Sync Data

```bash
# From repo root
python tools/sync_game_data.py
```

This copies `data/` → `game/data/` so Godot can load JSON files.

### Step 2: Run Godot

```bash
# Using Godot CLI
godot --path game

# Or open in Godot Editor:
# 1. Open Godot 4.2+
# 2. Import → select game/project.godot
# 3. Press F5
```

### Step 3: Play

1. Select a shift (01–10) from the dropdown
2. Click **Start**
3. Process tickets using keyboard shortcuts or by clicking the paper
4. After completing a shift, click **Next Shift** or press **Esc** to return

---

## Features

- **Shift Selector** — Play any shift 01–10
- **Persistent Progression** — Unlock shifts by completing them
- **Settings** — Configure SFX, VFX intensity, events, reduce motion
- **Keyboard + Mouse** — Full keyboard shortcuts plus click-on-paper input
- **Data-Driven** — All tickets load from JSON
- **Toast System** — Shows feedback messages and control hints
- **Meters** — Mood and Contradiction tracking
- **Rulebook Popup** — Auto-shows at shift start
- **Reality Tremor** — Visual feedback for high contradictions
- **3D Office Backdrop** — World-space UI rendered on paper on desk
- **Random Events** — Absurd office interruptions during shifts
- **Next Shift** — Continue to next shift after completion

---

## Save File

The game stores progress and settings in:

```
user://save.json
```

**Windows location:** `%APPDATA%\Godot\app_userdata\The Stamp Office\save.json`

To reset progress, click "Reset Progress" in the main menu, or delete the save file.

---

## Files

| File | Purpose |
|------|---------|
| `project.godot` | Config + autoloads |
| `scripts/DataLoader.gd` | JSON loader (tickets, toasts, rules) |
| `scripts/GameState.gd` | Stores selected shift |
| `scripts/Save.gd` | Persistent save + settings |
| `scripts/Main.gd` | Menu + shift selector + settings UI |
| `scripts/Shift.gd` | Gameplay logic + keyboard + tremor effects |
| `scripts/Sfx.gd` | Procedural audio synthesis |
| `scripts/ShiftEvents.gd` | Random interrupt events |
| `scripts/Office3D.gd` | 3D backdrop idle + tremor |
| `scenes/Main.tscn` | Main menu UI + settings popup |
| `scenes/Shift.tscn` | Shift gameplay UI + SubViewport |
| `scenes/Office3D.tscn` | 3D office scene (primitives) |
| `data/` | Synced JSON data |

---

## Notes

- **World-space UI**: The shift UI is rendered on a 3D paper on the desk. Use keyboard shortcuts or click the paper.
- **No movement controls**: This is intentional — you're a clerk at a desk, not exploring an office.
- **Tremor effect**: Also triggers camera shake and light flicker in the 3D scene.
- **Save system**: Automatically saves when completing a shift or changing settings.
