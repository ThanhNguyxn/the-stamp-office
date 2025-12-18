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

## 🚀 Quickstart

> **Status: Prototype Available**
> 
> A working prototype exists! Shift 01 is playable. The project follows documentation-first development — explore the design docs in `docs/` to understand the full vision.

```bash
# Clone the repository
git clone https://github.com/ThanhNguyxn/the-stamp-office.git
cd the-stamp-office

# Run the prototype (requires Godot 4.2+)
godot --path game

# Or explore the documentation
cd docs
```

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
│   ├── README.md              # Tools documentation
│   └── validate_data.py       # Data validator script
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
  - [x] Vision, style lock, meme safety, clip moments
  - [x] SHIFT_01 through SHIFT_10 scripts
  - [x] Endings document
- [x] **Phase 2: Data Architecture** — Define ticket/rule systems, dialogue structures ✓
  - [x] JSON schema definitions
  - [x] Shift 01–10 ticket data (127 tickets total)
  - [x] Rules data (40 rules across 10 shifts)
  - [x] Global toast pool (119 toasts)
  - [x] Data validator (multi-file, cross-ID)
- [/] **Phase 3: Prototype** — Initial Godot project, basic mechanics
  - [x] Godot project scaffold
  - [x] Shift 01 playable (loads JSON data)
  - [x] Data sync into game/data
  - [x] Shift selector (01–10)
  - [ ] Audio/visual polish
- [ ] **Phase 4: Vertical Slice** — Playable demo of one complete shift
- [ ] **Phase 5: Alpha** — Multiple shifts, core gameplay loop
- [ ] **Phase 6: Beta** — Polish, testing, community feedback
- [ ] **Phase 7: Release** — Launch the bureaucratic nightmare

> **Next up:** Phase 3 — Audio/visual polish, then Phase 4

---

## 🤝 Contributing

Contributions are welcome! Whether it's writing lore, designing tickets, suggesting features, or eventually writing code — we'd love your help.

Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a PR.

---

## 📜 Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## 🔒 Security

Found a vulnerability? Please review our [Security Policy](SECURITY.md) for responsible disclosure guidelines.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Meme Safety Note

> **All characters, organizations, brands, and bureaucratic entities in this project are entirely fictional.**
> 
> Any resemblance to real companies, government agencies, or soul-crushing workplaces is purely coincidental (and legally defensible). No real brands, teams, or people are referenced or parodied.

---

## ☕ Support

If you enjoy this project and want to support its development:

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/thanhnguyxn)

**Buy Me a Coffee:** [https://buymeacoffee.com/thanhnguyxn](https://buymeacoffee.com/thanhnguyxn)

---

<p align="center">
  <i>"Please take a number. Your reality will be processed in the order it was received."</i>
</p>
