# The Stamp Office

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/ThanhNguyxn/the-stamp-office)](https://github.com/ThanhNguyxn/the-stamp-office/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Engine: Godot (prototype)](https://img.shields.io/badge/Engine-Godot%20(prototype)-478cbf)](https://godotengine.org/)

> **Horror look. Comedy feel. Paperwork runs reality.**

A 3D low-poly absurdist narrative job simulation where bureaucracy bends the fabric of existence. PG-13 uncanny vibes — no gore, just existential dread delivered through diegetic UI: tickets, rules, and ominous system toasts.

---

## ✨ Features

- 🎫 **Diegetic UI Comedy** — Humor through in-world tickets and passive-aggressive system notifications
- 🏢 **Absurdist Bureaucracy** — Process paperwork that alters reality itself
- 🎨 **Low-Poly Aesthetic** — Uncanny 3D visuals between cozy and unsettling
- 🚶 **First-Person Exploration** — Walk around the office with WASD
- 📋 **Narrative Job Sim** — Your choices matter (if you filled out Form 27-B/6)

---

## 🎮 Controls

### Movement (First-Person)

| Key | Action |
|-----|--------|
| `W`/`A`/`S`/`D` | Walk around |
| `Shift` | Sprint |
| `Space` | Jump |
| Mouse | Look around |
| `Tab` | Toggle cursor mode |
| `E` | Focus on desk |
| `Esc` | Back to menu |

### Desk Workflow (Cursor Mode)

| Key | Action |
|-----|--------|
| `1` | Open folder |
| `2` | Inspect |
| `3` | Check rules |
| `4` | File ticket |
| `A`/`D` | Approve/Deny |

### How It Works

1. **Walk around** the office using WASD + mouse look
2. Press **E** to focus on the desk and work
3. In **cursor mode**, click the paper or use keyboard shortcuts
4. Press **Tab** to toggle between modes
5. Press **Esc** to return to menu

---

## 🚀 Quickstart

```bash
# Clone and enter
git clone https://github.com/ThanhNguyxn/the-stamp-office.git
cd the-stamp-office

# Sync data
python tools/sync_game_data.py

# Run (Godot 4.2+)
godot --path game
```

Or open `game/project.godot` in Godot Editor and press **F5**.

---

## 📁 Structure

```
the-stamp-office/
├── docs/           # Design documents
├── data/           # Game data (JSON)
├── tools/          # Dev utilities
├── game/           # Godot 4 project
└── README.md
```

---

## 🗺️ Roadmap

- [x] **Phase 0-1:** Repository + design docs
- [x] **Phase 2:** Data architecture (127 tickets, 40 rules, 119 toasts)
- [x] **Phase 3:** Godot prototype scaffold
- [x] **Phase 4:** Vertical slice complete
  - [x] Rulebook, tremor VFX, 3D office, SFX
  - [x] Random interrupt events
- [x] **Phase 5:** Alpha features
  - [x] Persistent progression + save system
  - [x] First-person WASD movement
  - [x] Expanded 3D office map
  - [x] Cursor/look mode toggle
  - [ ] Story/lore integration
  - [ ] Ending variations
- [ ] **Phase 6:** Beta
- [ ] **Phase 7:** Release

---

## 🔧 Troubleshooting

**WASD doesn't work?** → Press **Tab** to enter LOOK mode

**Can't click paper?** → Press **Tab** or **E** to enter CURSOR mode

---

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting PRs.

---

## 📄 License

MIT License — see [LICENSE](LICENSE)

---

## ☕ Support

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/thanhnguyxn)

---

<p align="center">
  <i>"Please take a number. Your reality will be processed in the order it was received."</i>
</p>
