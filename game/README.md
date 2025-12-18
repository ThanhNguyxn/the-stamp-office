# The Stamp Office - Game

Godot 4.x project for **The Stamp Office**.

---

## Status: Shift 01 Playable ✅

---

## Run Shift 01

1. Install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot → **Import** → select `game/project.godot`
3. Press **F5** to run
4. Click **Start Shift 01**

---

## How It Works

1. **DataLoader.gd** loads `shift01.json` and `toasts.json`
2. **Shift.gd** displays tickets one-by-one
3. Player clicks stamp buttons (APPROVED, DENIED, etc.)
4. Toast displays, meters update
5. After 12 tickets: "Shift Complete"

---

## Files

| File | Purpose |
|------|---------|
| `project.godot` | Config + DataLoader autoload |
| `scenes/Main.tscn` | Main menu |
| `scenes/Shift.tscn` | Shift gameplay UI |
| `scripts/DataLoader.gd` | JSON loader |
| `scripts/Main.gd` | Menu logic |
| `scripts/Shift.gd` | Gameplay logic |
| `data/` | JSON data files |
