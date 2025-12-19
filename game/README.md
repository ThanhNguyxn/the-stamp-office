# The Stamp Office - Game

Godot 4.x prototype for **The Stamp Office**.

---

## Status: Shifts 01–10 Playable ✅

All 10 shifts are playable via the shift selector!

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
3. Process tickets by clicking stamp buttons
4. After completing a shift, click **Next Shift** or **Back to Menu**

---

## Features

- **Shift Selector** — Play any shift 01–10
- **Persistent Progression** — Unlock shifts by completing them
- **Settings** — Configure SFX, VFX intensity, events, reduce motion
- **Data-Driven** — All tickets load from JSON
- **Toast System** — Shows feedback messages
- **Meters** — Mood and Contradiction tracking
- **Rulebook Popup** — Auto-shows at shift start
- **Reality Tremor** — Visual feedback for high contradictions
- **3D Office Backdrop** — Rendered via SubViewport behind UI
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
| `scripts/Shift.gd` | Gameplay logic + tremor effects |
| `scripts/Sfx.gd` | Procedural audio synthesis |
| `scripts/ShiftEvents.gd` | Random interrupt events |
| `scripts/Office3D.gd` | 3D backdrop idle + tremor |
| `scenes/Main.tscn` | Main menu UI + settings popup |
| `scenes/Shift.tscn` | Shift gameplay UI + SubViewport |
| `scenes/Office3D.tscn` | 3D office scene (primitives) |
| `data/` | Synced JSON data |

---

## Notes

- **3D backdrop**: The Shift screen renders a 3D office backdrop via SubViewport. Uses only built-in primitives (no external assets).
- **Tremor effect**: Also triggers camera shake and light flicker in the 3D scene.
- **Save system**: Automatically saves when completing a shift or changing settings.
