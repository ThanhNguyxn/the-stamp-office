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
- **Data-Driven** — All tickets load from JSON
- **Toast System** — Shows feedback messages
- **Meters** — Mood and Contradiction tracking
- **Next Shift** — Continue to next shift after completion

---

## Files

| File | Purpose |
|------|---------|
| `project.godot` | Config + autoloads |
| `scripts/DataLoader.gd` | JSON loader |
| `scripts/GameState.gd` | Stores selected shift |
| `scripts/Main.gd` | Menu + shift selector |
| `scripts/Shift.gd` | Gameplay logic |
| `scenes/Main.tscn` | Main menu UI |
| `scenes/Shift.tscn` | Shift gameplay UI |
| `data/` | Synced JSON data |
