# The Stamp Office - Game

Godot 4.x project for **The Stamp Office**.

---

## Status: Shift 01 Playable ✅

Shift 01 now loads ticket data from JSON and is fully playable!

---

## Requirements

- [Godot 4.2+](https://godotengine.org/download) (Standard or .NET)
- Data files in `game/data/` (already included)

---

## Run Shift 01

### Option 1: Godot Editor

1. Download and install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot and click **Import**
3. Navigate to `game/project.godot` and select it
4. Click **Import & Edit**
5. Press **F5** or click the **Play** button
6. Click **"Start Shift 01"** on the main menu

### Option 2: Command Line

```bash
# Navigate to repo
cd the-stamp-office

# Run with Godot (adjust path to your installation)
godot --path game
```

---

## How It Works

1. **DataLoader.gd** (autoload) loads ticket and toast JSON on startup
2. **Shift.gd** displays tickets one-by-one from `shift01.json`
3. Player clicks stamp buttons (APPROVED, DENIED, MAYBE, etc.)
4. Outcome toast is displayed from `toasts.json`
5. Mood and Contradiction meters update based on deltas
6. After 12 tickets: "Shift Complete" screen with final stats

---

## Project Structure

```
game/
├── project.godot           # Godot config (DataLoader autoload)
├── .gitignore
├── data/                   # JSON data files
│   ├── tickets/shift01.json ... shift10.json
│   ├── toasts/toasts.json
│   └── rules/rules.json
├── scenes/
│   ├── Main.tscn           # Main menu
│   └── Shift.tscn          # Shift gameplay
└── scripts/
    ├── DataLoader.gd       # JSON loader (autoload)
    ├── Main.gd             # Menu logic
    └── Shift.gd            # Shift gameplay
```

---

## Current Status

- ✅ **Shift 01** playable with 12 tickets
- ✅ Toast system working
- ✅ Mood & Contradiction meters
- ⬜ Shift 02–10 (data exists, need shift selector)
- ⬜ Audio/visual polish
- ⬜ Save system
