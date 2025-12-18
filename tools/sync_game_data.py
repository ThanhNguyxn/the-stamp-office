#!/usr/bin/env python3
"""
Sync canonical data/ folder into game/data/ for Godot.

Usage:
    python tools/sync_game_data.py

This copies:
    data/tickets/*.json     -> game/data/tickets/
    data/toasts/toasts.json -> game/data/toasts/
    data/rules/rules.json   -> game/data/rules/
"""

import shutil
from pathlib import Path

def main():
    # Paths relative to repo root
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    
    src_data = repo_root / "data"
    dst_data = repo_root / "game" / "data"
    
    if not src_data.exists():
        print(f"ERROR: Source data/ folder not found at {src_data}")
        return 1
    
    print("=" * 50)
    print("Syncing data/ -> game/data/")
    print("=" * 50)
    
    copied = 0
    
    # Sync tickets
    src_tickets = src_data / "tickets"
    dst_tickets = dst_data / "tickets"
    dst_tickets.mkdir(parents=True, exist_ok=True)
    
    for f in sorted(src_tickets.glob("*.json")):
        dst = dst_tickets / f.name
        shutil.copy2(f, dst)
        print(f"  ✓ tickets/{f.name}")
        copied += 1
    
    # Sync toasts
    src_toasts = src_data / "toasts" / "toasts.json"
    dst_toasts = dst_data / "toasts"
    dst_toasts.mkdir(parents=True, exist_ok=True)
    
    if src_toasts.exists():
        shutil.copy2(src_toasts, dst_toasts / "toasts.json")
        print(f"  ✓ toasts/toasts.json")
        copied += 1
    
    # Sync rules
    src_rules = src_data / "rules" / "rules.json"
    dst_rules = dst_data / "rules"
    dst_rules.mkdir(parents=True, exist_ok=True)
    
    if src_rules.exists():
        shutil.copy2(src_rules, dst_rules / "rules.json")
        print(f"  ✓ rules/rules.json")
        copied += 1
    
    print("-" * 50)
    print(f"Synced {copied} files to game/data/")
    print("=" * 50)
    
    return 0

if __name__ == "__main__":
    exit(main())
