# The Stamp Office - Game

Godot 4.x prototype for **The Stamp Office**.

---

## Status: Alpha Complete ✅

All 10 shifts playable with:
- First-person exploration
- Story/intercom messages
- Three endings
- Secret stamp mechanic

---

## 🎮 Controls

### Two Modes

| Mode | Mouse | Movement | Paper UI |
|------|-------|----------|----------|
| **LOOK** (default) | Captured | WASD works | Cannot click |
| **CURSOR** | Visible | Disabled | Click or use shortcuts |

### Movement (LOOK Mode)

| Key | Action |
|-----|--------|
| `W`/`A`/`S`/`D` | Walk |
| `Shift` | Sprint |
| `Space` | Jump |
| Mouse | Look around |
| Arrow keys | Walk (alternate) |

### Mode Switching

| Key | Action |
|-----|--------|
| `Tab` | Toggle LOOK/CURSOR mode |
| `E` | Focus on desk (enters cursor mode) |
| `Esc` | Back to menu |

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
| `N` | Secret stamp (if unlocked) |

---

## The Office

Explore the expanded 3D office:
- **Processing Desk** - Where you work
- **Break Room B** - Closed for maintenance
- **Archive** - Files and cabinets
- **Stairwell** - DO NOT ENTER

Walk around using WASD, press E to work at the desk.

---

## Story

Intercom messages play at shift start, mid-shift, and end. Pay attention to hints about the secret ending.

---

## Endings

Three endings based on your choices:

1. **Clock Out** - Follow the rules, be a good employee
2. **Official** - Break protocol, become The Office
3. **Not A Thing** - Use the secret stamp on specific tickets

---

## Run the Prototype

```bash
# Sync data
python tools/sync_game_data.py

# Run Godot
godot --path game
```

Or open `game/project.godot` and press **F5**.

---

## Save File

Progress saved to: `user://save.json`

**Windows:** `%APPDATA%\Godot\app_userdata\The Stamp Office\save.json`

---

## Debug HUD

Green overlay shows:
- Current mode (LOOK/CURSOR)
- Position and velocity
- Input state
