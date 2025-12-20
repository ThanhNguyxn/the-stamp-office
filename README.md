# The Stamp Office

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/ThanhNguyxn/the-stamp-office)](https://github.com/ThanhNguyxn/the-stamp-office/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Engine: Godot (prototype)](https://img.shields.io/badge/Engine-Godot%20(prototype)-478cbf)](https://godotengine.org/)

> **Horror look. Comedy feel. Paperwork runs reality.**

A 3D low-poly absurdist narrative job simulation where bureaucracy bends the fabric of existence. PG-13 uncanny vibes — no gore, just existential dread delivered through diegetic UI: tickets, rules, and ominous system toasts.

---

## ✨ Features

- 🎫 **Diegetic UI Comedy** — In-world tickets and passive-aggressive notifications
- 🏢 **Absurdist Bureaucracy** — Paperwork that alters reality
- 🎨 **Low-Poly Aesthetic** — Uncanny 3D visuals
- 🚶 **First-Person Exploration** — Walk around an expanded office
- 📖 **Story Integration** — Intercom messages and lore per shift
- 🎬 **Multiple Endings** — Three endings based on your choices

---

## 🎮 Controls

### Movement & Exploration

| Key | Action |
|-----|--------|
| `W`/`A`/`S`/`D` | Walk |
| `Shift` | Sprint |
| `Space` | Jump |
| Mouse | Look around |
| `Tab` | Toggle cursor mode |
| `E` | Interact (desk, doors, objects) |
| `Esc` | Back / Menu |

### Interaction System

- **Look at objects** to see interaction hints
- **Desk**: Press `E` while looking at desk to sit down and work
- **Doors**: Press `E` to open/close doors
- **Locked doors**: Some doors are locked (Manager's office, Break Room B...)
- **Room triggers**: Entering new areas shows flavor text

### Workflow (At Desk)

| Key | Action |
|-----|--------|
| `1` | Open folder |
| `2` | Inspect ticket |
| `3` | Check rules |
| `4` | File ticket |
| `A` | Approve |
| `D` | Deny |
| `R` | Open rulebook |
| `E` / `Esc` | Stand up from desk |

---

## 🚀 Quickstart

```bash
git clone https://github.com/ThanhNguyxn/the-stamp-office.git
cd the-stamp-office
python tools/sync_game_data.py
godot --path game
```

---

## 🗺️ Roadmap

### Phase 0: Meta ✅
- [x] Repository setup (GitHub)
- [x] OSS templates (LICENSE, CODE_OF_CONDUCT, CONTRIBUTING, SECURITY)
- [x] Issue and PR templates
- [x] Project structure planning

### Phase 1: Foundation ✅
- [x] Core design documents (`docs/vision.md`)
- [x] Style lock (`docs/style_lock.md`)
- [x] Meme safety guidelines (`docs/meme_safety.md`)
- [x] Clip moment board (`docs/clip_moment_board.md`)
- [x] Shift scripts (`docs/script/SHIFT_01.md` – `SHIFT_10.md`)
- [x] Endings design (`docs/script/ENDINGS.md`)

### Phase 2: Data Architecture ✅
- [x] JSON schema definitions (`data/schema.json`)
- [x] 127 tickets across 10 shifts (`data/tickets/`)
- [x] 40 rules (4 per shift) (`data/rules/rules.json`)
- [x] 119 toast messages (`data/toasts/toasts.json`)
- [x] Data validation tool (`tools/validate_data.py`)
- [x] Data sync tool (`tools/sync_game_data.py`)

### Phase 3: Prototype Scaffold ✅
- [x] Godot 4.x project setup (`game/project.godot`)
- [x] Main menu scene (`game/scenes/Main.tscn`)
- [x] Shift gameplay scene (`game/scenes/Shift.tscn`)
- [x] DataLoader autoload (`game/scripts/DataLoader.gd`)
- [x] GameState autoload (`game/scripts/GameState.gd`)
- [x] Basic UI layout (paper, buttons, toast)

### Phase 4: Vertical Slice ✅
- [x] 3D office backdrop (`game/scenes/Office3D.tscn`)
- [x] Clerk silhouette with idle animation
- [x] World-space paper UI (viewport texture on 3D mesh)
- [x] Raycast mouse-to-paper input forwarding
- [x] Workflow system (Open → Inspect → Rules → File → Stamp)
- [x] Rulebook popup with per-shift rules
- [x] Mood and Contradiction meters
- [x] Toast system for feedback messages
- [x] Procedural SFX (`game/scripts/Sfx.gd`)
- [x] Reality tremor VFX (camera shake + light flicker)
- [x] Random interrupt events (`game/scripts/ShiftEvents.gd`)
- [x] Shift selector (play any shift 01–10)

### Phase 5: Alpha ✅
- [x] Persistent progression (`game/scripts/Save.gd`)
- [x] Settings system (SFX, VFX intensity, events, reduce motion)
- [x] First-person WASD movement (`game/scripts/Player.gd`)
- [x] Mouse look with pitch/yaw
- [x] Sprint and jump
- [x] Cursor/look mode toggle (Tab/E)
- [x] Expanded 3D office map:
  - [x] Main desk room
  - [x] Corridors
  - [x] Break Room B
  - [x] Archive room
  - [x] Stairwell (DO NOT ENTER)
  - [x] Label3D signs
  - [x] Trigger zones
  - [x] Volumetric fog
  - [x] Ambient light flicker
- [x] Story/lore integration (`game/scripts/StoryDirector.gd`):
  - [x] Intercom messages per shift (start/mid/end)
  - [x] Hints for secret ending
- [x] Ending variations (`game/scenes/Ending.tscn`):
  - [x] Clock Out (compliance ending)
  - [x] Official (dissolution ending)
  - [x] Not A Thing (secret/transcendence ending)
  - [x] Secret stamp mechanic (NOT_A_THING)
  - [x] Level 7 deny tracking
  - [x] Ending determination logic
- [x] Enhanced 3D office graphics (low-poly Phở Anh Hai style):
  - [x] Detailed desk with monitor, keyboard, mug, papers, lamp
  - [x] Office chair with wheels, pole, armrests
  - [x] Filing cabinets with drawer details and handles
  - [x] Plants with stems, dirt, leaves
  - [x] Ceiling light fixtures
  - [x] Wall decorations (clock, posters)
  - [x] Break room props (magazines, coffee mug)
- [x] Horror events system (`game/scripts/HorrorEvents.gd`):
  - [x] 8 event types (light flicker, whisper, screen glitch, etc.)
  - [x] Tension system increases with wrong decisions
  - [x] Events intensity scales with shift number
  - [x] Respects accessibility settings (jumpscares toggle)
- [x] Horror atmosphere:
  - [x] Darker lighting with desaturated colors
  - [x] Increased fog density
  - [x] SSAO shadows
  - [x] Screen shader effects (glitch, static, vignette)
- [x] Settings menu improvements:
  - [x] Horror events toggle
  - [x] Screen shake toggle
  - [x] VFX intensity slider
- [x] Realistic first-person body model:
  - [x] Cylindrical arms with upper arm, forearm, wrist
  - [x] Detailed hands with fingers (4 fingers + thumb per hand)
  - [x] Capsule-based torso with belt and buckle
  - [x] Leg model with thigh, shin, and shoes
  - [x] Smooth arm bob animation while walking
- [x] Enhanced office map details:
  - [x] Floor carpets and patterns
  - [x] Crown molding along ceiling
  - [x] Hanging lights with chains
  - [x] Wall electrical outlets and switches
  - [x] Ceiling air vents and wall pipes
  - [x] Multiple visitor chairs with side table
  - [x] Hallway benches, clocks, fire extinguishers
  - [x] Direction signs throughout
  - [x] Break room: sink, coffee maker, toaster, wall cabinet
  - [x] Archive: shelf units, old lamp, filing boxes, old desk
  - [x] Reception: computer monitor, bell, brochure stand
  - [x] Work area: in/out trays, stapler, stamp pad, nameplate
  - [x] Ambient details: scuff marks, ceiling stains, cobwebs

### Phase 6: Beta 🔄
- [ ] Polish and bug fixes
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] Additional ambient details
- [ ] Sound design improvements

### Phase 7: Release 📦
- [ ] Final testing
- [ ] Build exports (Windows, Linux, Mac, Web)
- [ ] itch.io / Steam page
- [ ] Launch trailer
- [ ] Post-launch support

---

## 📁 Structure

```
the-stamp-office/
├── docs/                      # Design documents
│   ├── vision.md              # Core pitch and pillars
│   ├── style_lock.md          # Visual/audio rules
│   ├── meme_safety.md         # Humor guidelines
│   ├── clip_moment_board.md   # Shareable moments
│   └── script/                # Per-shift scripts + endings
├── data/                      # Game data (JSON)
│   ├── schema.json            # Data schemas
│   ├── tickets/               # 127 tickets
│   ├── rules/                 # 40 rules
│   └── toasts/                # 119 toasts
├── tools/                     # Dev utilities
│   ├── validate_data.py       # Validation
│   └── sync_game_data.py      # Copy to game/data/
├── game/                      # Godot 4 project
│   ├── scenes/                # .tscn files
│   ├── scripts/               # .gd scripts
│   └── data/                  # Synced JSON
└── README.md
```

---

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📄 License

MIT — see [LICENSE](LICENSE)

---

## ☕ Support

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/thanhnguyxn)

---

<p align="center">
  <i>"Please take a number. Your reality will be processed in the order it was received."</i>
</p>
