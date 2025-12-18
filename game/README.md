# The Stamp Office - Game

Godot 4.x project scaffold for **The Stamp Office**.

---

## Status: Scaffold Only

This is the initial project structure. JSON data loading will be added in the next commit.

---

## Requirements

- [Godot 4.2+](https://godotengine.org/download) (Standard or .NET)

---

## How to Open

1. Download and install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot and click **Import**
3. Navigate to `game/project.godot` and select it
4. Click **Import & Edit**
5. Press **F5** or click **Run** to launch

---

## What Exists

| File | Purpose |
|------|---------|
| `project.godot` | Godot project configuration |
| `scenes/Main.tscn` | Main menu (title + buttons) |
| `scenes/Shift.tscn` | Shift gameplay UI placeholders |
| `scripts/Main.gd` | Menu button handlers |
| `scripts/Shift.gd` | Shift placeholder (Back button works) |

---

## Project Structure

```
game/
├── project.godot
├── .gitignore
├── scenes/
│   ├── Main.tscn      # Main menu
│   └── Shift.tscn     # Shift gameplay
└── scripts/
    ├── Main.gd        # Menu logic
    └── Shift.gd       # Shift logic (scaffold)
```

---

## Next Steps

- [ ] Add `DataLoader.gd` for JSON loading
- [ ] Connect ticket data to Shift UI
- [ ] Implement stamp button generation
- [ ] Add toast display system
