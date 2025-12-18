#!/usr/bin/env python3
"""
Data Validator for The Stamp Office

Validates:
- All toast_id references exist in toasts.json
- All text and attachment fields are <= 8 words
- All IDs are unique within their files

Usage:
    python tools/validate_data.py

Exit codes:
    0 = All checks passed
    1 = One or more checks failed
"""

import json
import sys
from pathlib import Path


def load_json(filepath: Path) -> dict:
    """Load and parse a JSON file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def count_words(text: str) -> int:
    """Count words in a string."""
    return len(text.split())


def validate_word_count(text: str, max_words: int = 8) -> bool:
    """Check if text has <= max_words."""
    return count_words(text) <= max_words


def validate_tickets(tickets_data: dict, toast_ids: set) -> list:
    """Validate ticket data. Returns list of error messages."""
    errors = []
    seen_ids = set()
    
    for ticket in tickets_data.get('tickets', []):
        tid = ticket.get('id', 'UNKNOWN')
        
        # Check unique ID
        if tid in seen_ids:
            errors.append(f"[TICKET] Duplicate ID: {tid}")
        seen_ids.add(tid)
        
        # Check text word count
        text = ticket.get('text', '')
        if not validate_word_count(text):
            errors.append(f"[TICKET {tid}] Text exceeds 8 words: \"{text}\"")
        
        # Check attachment word count
        attachment = ticket.get('attachment', '')
        if not validate_word_count(attachment):
            errors.append(f"[TICKET {tid}] Attachment exceeds 8 words: \"{attachment}\"")
        
        # Check toast references
        for stamp, outcome in ticket.get('outcomes', {}).items():
            toast_id = outcome.get('toast_id', '')
            if toast_id and toast_id not in toast_ids:
                errors.append(f"[TICKET {tid}] Unknown toast_id: {toast_id}")
    
    return errors


def validate_rules(rules_data: dict) -> list:
    """Validate rules data. Returns list of error messages."""
    errors = []
    seen_ids = set()
    
    for rule in rules_data.get('rules', []):
        rid = rule.get('id', 'UNKNOWN')
        
        # Check unique ID
        if rid in seen_ids:
            errors.append(f"[RULE] Duplicate ID: {rid}")
        seen_ids.add(rid)
        
        # Check text word count
        text = rule.get('text', '')
        if not validate_word_count(text):
            errors.append(f"[RULE {rid}] Text exceeds 8 words: \"{text}\"")
    
    return errors


def validate_toasts(toasts_data: dict) -> tuple:
    """Validate toasts data. Returns (errors, set of valid IDs)."""
    errors = []
    toast_ids = set()
    
    for toast in toasts_data.get('toasts', []):
        tid = toast.get('id', 'UNKNOWN')
        
        # Check unique ID
        if tid in toast_ids:
            errors.append(f"[TOAST] Duplicate ID: {tid}")
        toast_ids.add(tid)
    
    return errors, toast_ids


def main():
    """Run all validations."""
    # Determine base path (repo root)
    script_path = Path(__file__).resolve()
    repo_root = script_path.parent.parent
    
    data_path = repo_root / 'data'
    
    # File paths
    tickets_file = data_path / 'tickets' / 'shift01.json'
    rules_file = data_path / 'rules' / 'rules.json'
    toasts_file = data_path / 'toasts' / 'toasts.json'
    
    all_errors = []
    
    print("=" * 50)
    print("The Stamp Office - Data Validator")
    print("=" * 50)
    print()
    
    # Load toasts first (needed for reference checking)
    print(f"Loading {toasts_file.name}...")
    try:
        toasts_data = load_json(toasts_file)
        toast_errors, toast_ids = validate_toasts(toasts_data)
        all_errors.extend(toast_errors)
        print(f"  Found {len(toast_ids)} toast IDs")
    except FileNotFoundError:
        print(f"  ERROR: File not found!")
        all_errors.append(f"[FILE] Missing: {toasts_file}")
        toast_ids = set()
    except json.JSONDecodeError as e:
        print(f"  ERROR: Invalid JSON - {e}")
        all_errors.append(f"[FILE] Invalid JSON: {toasts_file}")
        toast_ids = set()
    
    # Load and validate rules
    print(f"Loading {rules_file.name}...")
    try:
        rules_data = load_json(rules_file)
        rule_errors = validate_rules(rules_data)
        all_errors.extend(rule_errors)
        print(f"  Found {len(rules_data.get('rules', []))} rules")
    except FileNotFoundError:
        print(f"  ERROR: File not found!")
        all_errors.append(f"[FILE] Missing: {rules_file}")
    except json.JSONDecodeError as e:
        print(f"  ERROR: Invalid JSON - {e}")
        all_errors.append(f"[FILE] Invalid JSON: {rules_file}")
    
    # Load and validate tickets
    print(f"Loading {tickets_file.name}...")
    try:
        tickets_data = load_json(tickets_file)
        ticket_errors = validate_tickets(tickets_data, toast_ids)
        all_errors.extend(ticket_errors)
        print(f"  Found {len(tickets_data.get('tickets', []))} tickets")
    except FileNotFoundError:
        print(f"  ERROR: File not found!")
        all_errors.append(f"[FILE] Missing: {tickets_file}")
    except json.JSONDecodeError as e:
        print(f"  ERROR: Invalid JSON - {e}")
        all_errors.append(f"[FILE] Invalid JSON: {tickets_file}")
    
    # Print results
    print()
    print("=" * 50)
    
    if all_errors:
        print(f"FAIL - {len(all_errors)} error(s) found:")
        print("=" * 50)
        for error in all_errors:
            print(f"  ✗ {error}")
        print()
        sys.exit(1)
    else:
        print("PASS - All checks passed!")
        print("=" * 50)
        print()
        sys.exit(0)


if __name__ == '__main__':
    main()
