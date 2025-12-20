# The Stamp Office - Game

Godot 4.x prototype for **The Stamp Office**.

---

## Status: Alpha Complete ✅

All 10 shifts playable with:
- First-person exploration
- Story/intercom messages
- Three endings
- Secret stamp mechanic
- Interactive office environment

---

## 🎮 Controls

### Two Modes

| Mode | Mouse | Movement | Interaction |
|------|-------|----------|-------------|
| **LOOK** (default) | Captured | WASD works | E to interact |
| **CURSOR** | Visible | Disabled | Click UI elements |

### Movement & Exploration (LOOK Mode)

| Key | Action |
|-----|--------|
| `W`/`A`/`S`/`D` | Walk |
| `Shift` | Sprint |
| `Space` | Jump |
| Mouse | Look around |

### Interaction System

| Key | Action |
|-----|--------|
| `E` | Interact with object you're looking at |
| `Tab` | Toggle LOOK/CURSOR mode |
| `Esc` | Back / Stand up / Menu |

**Interactable objects:**
- **Desk** - Sit down to process tickets
- **Doors** - Open/close (some are locked)
- **Signs** - Passive-aggressive office decor

**Hints appear on screen** when looking at interactable objects.

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
| `E` / `Esc` | Stand up from desk |

---

## The Office

Explore the expanded 3D office:
- **Processing Desk** - Where you work
- **Lobby** - Welcome back. Your shift never ends.
- **Break Room** - The coffee machine watches.
- **Printer Room** - The printer breathes. Do not wake it.
- **Archive** - The files remember what you forgot.
- **Manager's Office** - DO NOT KNOCK.
- **Break Room B** - Does not exist. You did not see this.
- **Stairwell** - ACCESS DENIED. Floor -1 is classified.

Walk around using WASD, look at objects with mouse, press E to interact.

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
