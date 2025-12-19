# The Stamp Office - Game

Godot 4.x prototype for **The Stamp Office**.

---

## Status: Shifts 01–10 Playable ✅

All 10 shifts are playable via the shift selector!

---

## 🎮 Controls

This is a **first-person desk workflow game**. Walk around the office and interact with the desk to process paperwork.

### Movement

| Key | Action |
|-----|--------|
| `W`/`A`/`S`/`D` | Walk |
| `Shift` | Sprint |
| Mouse | Look around |
| `Tab` | Toggle cursor mode |
| `E` | Focus/unfocus desk |
| `Esc` | Leave desk / Back |

### Cursor Mode vs Look Mode

- **Look Mode** (default): Mouse is captured, you can walk and look around
- **Cursor Mode**: Mouse is visible, you can click the paper UI on the desk

Press **Tab** to switch modes, or **E** to focus on the desk (auto-enables cursor mode).

### Desk Workflow (in Cursor Mode)

| Key | Action |
|-----|--------|
| `1` | Open folder |
| `2` | Inspect attachment |
| `3` | Check rules |
| `4` | File ticket |
| `R` | Open rulebook |
| `A` | Approve stamp |
| `D` | Deny stamp |
| `Space`/`Enter` | Close rulebook |

### Interrupt Events

When an event popup appears, press `A` or `B` to choose.

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

1. Walk around using WASD + mouse
2. Press **E** near the desk to focus on paperwork
3. Use keyboard shortcuts (1-4, A/D) or click the paper to work
4. Press **Esc** to leave or **Tab** to toggle cursor

---

## Features

- **First-Person Movement** — Walk around the office with WASD + mouse look
- **Cursor/Look Mode Toggle** — Tab switches between walking and clicking
- **Desk Focus** — E key snaps camera to desk for paperwork
- **Shift Selector** — Play any shift 01–10
- **Persistent Progression** — Unlock shifts by completing them
- **Settings** — Configure SFX, VFX intensity, events, reduce motion
- **Keyboard + Mouse** — Full keyboard shortcuts plus click-on-paper input
- **Data-Driven** — All tickets load from JSON
- **Toast System** — Shows feedback messages and control hints
- **Meters** — Mood and Contradiction tracking
- **Rulebook Popup** — Auto-shows at shift start
- **Reality Tremor** — Visual feedback for high contradictions
- **3D Office** — Walk around the office environment
- **Random Events** — Absurd office interruptions during shifts

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
| `project.godot` | Config + autoloads + input actions |
| `scripts/DataLoader.gd` | JSON loader (tickets, toasts, rules) |
| `scripts/GameState.gd` | Stores selected shift |
| `scripts/Save.gd` | Persistent save + settings |
| `scripts/Main.gd` | Menu + shift selector + settings UI |
| `scripts/Shift.gd` | Gameplay logic + cursor mode + raycast |
| `scripts/PlayerController.gd` | First-person movement + desk focus |
| `scripts/Sfx.gd` | Procedural audio synthesis |
| `scripts/ShiftEvents.gd` | Random interrupt events |
| `scripts/Office3D.gd` | 3D backdrop idle + tremor |
| `scenes/Main.tscn` | Main menu UI + settings popup |
| `scenes/Shift.tscn` | Shift gameplay UI + SubViewport |
| `scenes/Office3D.tscn` | 3D office scene + Player rig |
| `data/` | Synced JSON data |

---

## Notes

- **First-person movement**: WASD to walk, mouse to look. Press Tab or E to toggle between walking and clicking the desk.
- **Cursor mode**: Required to click the paper UI. Mouse must be visible.
- **Tremor effect**: Triggers camera shake and light flicker in the 3D scene.
- **Save system**: Automatically saves when completing a shift or changing settings.
