# The Stamp Office

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/ThanhNguyxn/the-stamp-office)](https://github.com/ThanhNguyxn/the-stamp-office/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Engine: Godot (prototype)](https://img.shields.io/badge/Engine-Godot%20(prototype)-478cbf)](https://godotengine.org/)

> **Horror look. Comedy feel. Paperwork runs reality.**

A 3D low-poly absurdist narrative job simulation where bureaucracy bends the fabric of existence. PG-13 uncanny vibes — no gore, just existential dread delivered through diegetic UI: tickets, rules, and ominous system toasts.

---

## ✨ Features

- 🎫 **Diegetic UI Comedy** — Humor delivered through in-world tickets, byzantine rule systems, and passive-aggressive system notifications
- 🏢 **Absurdist Bureaucracy** — Process paperwork that subtly (or not so subtly) alters reality itself
- 🎨 **Low-Poly Aesthetic** — Deliberately uncanny 3D visuals that walk the line between cozy and unsettling
- 📋 **Narrative Job Sim** — Your choices matter... assuming you filled out Form 27-B/6 correctly
- 🔮 **Documentation-First Development** — Building the lore before the code

---

## 🎬 Preview

<!-- GIF placeholder: Replace with actual gameplay GIF when available -->
![Gameplay Preview](https://via.placeholder.com/800x450.png?text=Gameplay+GIF+Coming+Soon)

*Actual gameplay footage coming soon™*

---

## 🎮 Controls

### Movement (First-Person)

| Key | Action |
|-----|--------|
| `W` / `A` / `S` / `D` | Walk around the office |
| `Shift` | Sprint |
| Mouse | Look around |
| `Tab` | Toggle cursor mode |
| `E` | Focus/unfocus desk |
| `Esc` | Back to menu |

### Desk Workflow (Cursor Mode)

| Key | Action |
|-----|--------|
| `1` | Open folder |
| `2` | Inspect attachment |
| `3` | Check rules |
| `4` | File ticket |
| `R` | Open rulebook |
| `A` | Approve stamp |
| `D` | Deny stamp |

### Mode Switching

- **LOOK mode** (default): Mouse captured, WASD moves you
- **CURSOR mode**: Mouse visible, click paper UI or use 1-4 shortcuts
- Press **Tab** to toggle, or **E** to focus on desk

---

## 🚀 Quickstart

> **Status: Prototype Complete**
> 
> All 10 shifts are playable via the shift selector!

```bash
# Clone the repository
git clone https://github.com/ThanhNguyxn/the-stamp-office.git
cd the-stamp-office

# Sync data into Godot project
python tools/sync_game_data.py

# Run the prototype (requires Godot 4.2+)
godot --path game

# Or explore the documentation
cd docs
```

> **Windows note:** If `godot` isn't in your PATH, use the full path:
> ```
> "C:\Program Files\Godot\Godot_v4.2-stable_win64.exe" --path game
> ```
> Or open `game/project.godot` directly in the Godot editor and press **F5**.

---

## 📁 Repository Structure

```
the-stamp-office/
├── docs/                      # Design documents and specifications
│   ├── vision.md              # Core pitch, pillars, structure
│   ├── style_lock.md          # Visual/audio/UI rules
│   ├── meme_safety.md         # Humor guidelines
│   ├── clip_moment_board.md   # Shareable moments catalog
│   └── script/                # Shift scripts and endings
│       ├── SHIFT_01.md … SHIFT_10.md
│       └── ENDINGS.md
├── data/                      # Game data files
│   ├── README.md              # Data structure documentation
│   ├── schema.json            # JSON schema definitions
│   ├── tickets/               # Per-shift ticket data
│   │   └── shift01.json … shift10.json
│   ├── rules/
│   │   └── rules.json         # All 40 rules (4 per shift)
│   └── toasts/
│       └── toasts.json        # Global toast pool (119 toasts)
├── prompts/                   # LLM prompts for content generation
├── tools/                     # Development utilities
│   ├── validate_data.py       # Data validator
│   └── sync_game_data.py      # Sync data/ → game/data/
├── game/                      # Godot 4 prototype
├── .github/                   # Issue/PR templates
├── LICENSE
├── README.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
└── SECURITY.md
```

---

## 🗺️ Roadmap

- [x] **Phase 0: Meta** — Repository setup, OSS templates ✓
- [x] **Phase 1: Foundation** — Core design documents, game bible ✓
- [x] **Phase 2: Data Architecture** — Define ticket/rule systems ✓
- [x] **Phase 3: Prototype** — Initial Godot project, basic mechanics ✓
- [x] **Phase 4: Vertical Slice** — Playable demo ✓
- [ ] **Phase 5: Alpha** — Multiple shifts, core gameplay loop
  - [x] Persistent progression
  - [x] Settings
  - [x] Save system
  - [x] First-person WASD movement
  - [x] Cursor/look mode toggle
  - [ ] Story/lore integration
  - [ ] Ending variations
- [ ] **Phase 6: Beta** — Polish, testing
- [ ] **Phase 7: Release**

---

## 🔧 Troubleshooting

### WASD doesn't work?

Make sure you're in **LOOK mode** (mouse captured). Press **Tab** to toggle. The debug HUD in the top-left shows your current mode.

### Can't click the paper UI?

Switch to **CURSOR mode** by pressing **Tab**. Your mouse becomes visible and you can click.

### "godot" command not recognized (Windows)

1. Use full path: `"C:\Program Files\Godot\Godot_v4.2-stable_win64.exe" --path game`
2. Or open `game/project.godot` in Godot Editor and press **F5**

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a PR.

---

## 📜 Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).

---

## 🔒 Security

Found a vulnerability? Please review our [Security Policy](SECURITY.md).

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file.

---

## ⚠️ Meme Safety Note

> **All characters, organizations, brands, and bureaucratic entities in this project are entirely fictional.**

---

## ☕ Support

If you enjoy this project and want to support its development:

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/thanhnguyxn)

**Buy Me a Coffee:** [https://buymeacoffee.com/thanhnguyxn](https://buymeacoffee.com/thanhnguyxn)

---

<p align="center">
  <i>"Please take a number. Your reality will be processed in the order it was received."</i>
</p>
