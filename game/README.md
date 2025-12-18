# The Stamp Office - Game

Godot 4.x project for **The Stamp Office**.

---

## Requirements

- [Godot 4.2+](https://godotengine.org/download) (Standard or .NET)
- Data files from `../data/` (copied to `game/data/` for editor use)

---

## Project Structure

```
game/
├── project.godot          # Godot project config
├── scenes/
│   ├── Main.tscn          # Main menu
│   └── Shift.tscn         # Shift gameplay scene
├── scripts/
│   ├── DataLoader.gd      # JSON data loader (autoload)
│   ├── Main.gd            # Main menu controller
│   └── Shift.gd           # Shift gameplay controller
└── data/                  # Copy of ../data/ for Godot
    ├── tickets/
    ├── toasts/
    └── rules/
```

---

## Run Shift 01

### Option 1: Godot Editor

1. Open Godot 4.2+
2. Click **Import** and select `game/project.godot`
3. Copy `data/` folder into `game/data/` if not already present:
   ```bash
   cp -r data game/data
   ```
4. Click **Run** (F5) or press the Play button
5. Click **Start Shift 01**

### Option 2: Command Line

```bash
# Copy data files
cp -r data game/data

# Run with Godot (adjust path to your Godot installation)
godot --path game
```

---

## How It Works

1. **DataLoader.gd** loads ticket and toast JSON on startup
2. **Shift.gd** displays tickets one-by-one
3. Player clicks stamp buttons (APPROVED, DENIED, MAYBE, etc.)
4. Outcome toast is displayed, mood/contradiction updated
5. After all tickets: "Shift Complete" screen

---

## Adding New Shifts

1. Ensure `data/tickets/shiftXX.json` exists
2. Update `Shift.gd` to call `DataLoader.load_shift(XX)`
3. Create a shift selector UI (future Phase 4 work)

---

## Current Status

- ✅ **Shift 01** playable
- ⬜ Shift 02–10 (data exists, UI selector needed)
- ⬜ Audio/visual polish
- ⬜ Save system
