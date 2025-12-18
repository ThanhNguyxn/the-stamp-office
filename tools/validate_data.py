#!/usr/bin/env python3
"""
Data Validator for The Stamp Office

Validates:
- All toast_id references exist in toasts.json
- All text and attachment fields are <= 8 words
- All IDs are unique across all ticket files
- Required keys exist in all data files

Usage:
    python tools/validate_data.py

Exit codes:
    0 = All checks passed
    1 = One or more checks failed
"""

import json
import sys
from pathlib import Path
from glob import glob


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


REQUIRED_TICKET_KEYS = ['id', 'shift', 'type', 'text', 'attachment', 'allowed_stamps', 'rarity', 'tags', 'outcomes']
REQUIRED_OUTCOME_KEYS = ['toast_id', 'mood_delta', 'contradiction_delta']
REQUIRED_RULE_KEYS = ['id', 'shift', 'text']
REQUIRED_TOAST_KEYS = ['id', 'text', 'rarity', 'tags']


def validate_tickets(tickets_data: dict, toast_ids: set, filename: str, global_ticket_ids: set) -> list:
    """Validate ticket data. Returns list of error messages."""
    errors = []
    
    for ticket in tickets_data.get('tickets', []):
        tid = ticket.get('id', 'UNKNOWN')
        
        # Check required keys
        for key in REQUIRED_TICKET_KEYS:
            if key not in ticket:
                errors.append(f"[{filename}] Ticket {tid} missing required key: {key}")
        
        # Check unique ID across all files
        if tid in global_ticket_ids:
            errors.append(f"[{filename}] Duplicate ticket ID across files: {tid}")
        global_ticket_ids.add(tid)
        
        # Check text word count
        text = ticket.get('text', '')
        if not validate_word_count(text):
            errors.append(f"[{filename}] Ticket {tid} text exceeds 8 words: \"{text}\"")
        
        # Check attachment word count
        attachment = ticket.get('attachment', '')
        if not validate_word_count(attachment):
            errors.append(f"[{filename}] Ticket {tid} attachment exceeds 8 words: \"{attachment}\"")
        
        # Check toast references and outcome keys
        for stamp, outcome in ticket.get('outcomes', {}).items():
            # Check required outcome keys
            for key in REQUIRED_OUTCOME_KEYS:
                if key not in outcome:
                    errors.append(f"[{filename}] Ticket {tid} outcome {stamp} missing key: {key}")
            
            toast_id = outcome.get('toast_id', '')
            if toast_id and toast_id not in toast_ids:
                errors.append(f"[{filename}] Ticket {tid} unknown toast_id: {toast_id}")
    
    return errors


def validate_rules(rules_data: dict) -> list:
    """Validate rules data. Returns list of error messages."""
    errors = []
    seen_ids = set()
    
    for rule in rules_data.get('rules', []):
        rid = rule.get('id', 'UNKNOWN')
        
        # Check required keys
        for key in REQUIRED_RULE_KEYS:
            if key not in rule:
                errors.append(f"[RULE] Rule {rid} missing required key: {key}")
        
        # Check unique ID
        if rid in seen_ids:
            errors.append(f"[RULE] Duplicate ID: {rid}")
        seen_ids.add(rid)
        
        # Check text word count
        text = rule.get('text', '')
        if not validate_word_count(text):
            errors.append(f"[RULE] Rule {rid} text exceeds 8 words: \"{text}\"")
    
    return errors


def validate_toasts(toasts_data: dict) -> tuple:
    """Validate toasts data. Returns (errors, set of valid IDs)."""
    errors = []
    toast_ids = set()
    
    for toast in toasts_data.get('toasts', []):
        tid = toast.get('id', 'UNKNOWN')
        
        # Check required keys
        for key in REQUIRED_TOAST_KEYS:
            if key not in toast:
                errors.append(f"[TOAST] Toast {tid} missing required key: {key}")
        
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
    tickets_dir = data_path / 'tickets'
    rules_file = data_path / 'rules' / 'rules.json'
    toasts_file = data_path / 'toasts' / 'toasts.json'
    
    all_errors = []
    file_results = {}  # Track per-file PASS/FAIL
    
    print("=" * 60)
    print("The Stamp Office - Data Validator")
    print("=" * 60)
    print()
    
    # Load toasts first (needed for reference checking)
    print(f"Loading {toasts_file.name}...")
    try:
        toasts_data = load_json(toasts_file)
        toast_errors, toast_ids = validate_toasts(toasts_data)
        all_errors.extend(toast_errors)
        toast_count = len(toast_ids)
        print(f"  Found {toast_count} toast IDs")
        file_results['toasts.json'] = 'PASS' if not toast_errors else 'FAIL'
    except FileNotFoundError:
        print(f"  ERROR: File not found!")
        all_errors.append(f"[FILE] Missing: {toasts_file}")
        toast_ids = set()
        file_results['toasts.json'] = 'FAIL'
    except json.JSONDecodeError as e:
        print(f"  ERROR: Invalid JSON - {e}")
        all_errors.append(f"[FILE] Invalid JSON: {toasts_file}")
        toast_ids = set()
        file_results['toasts.json'] = 'FAIL'
    
    # Load and validate rules
    print(f"Loading {rules_file.name}...")
    try:
        rules_data = load_json(rules_file)
        rule_errors = validate_rules(rules_data)
        all_errors.extend(rule_errors)
        rule_count = len(rules_data.get('rules', []))
        print(f"  Found {rule_count} rules")
        file_results['rules.json'] = 'PASS' if not rule_errors else 'FAIL'
    except FileNotFoundError:
        print(f"  ERROR: File not found!")
        all_errors.append(f"[FILE] Missing: {rules_file}")
        file_results['rules.json'] = 'FAIL'
    except json.JSONDecodeError as e:
        print(f"  ERROR: Invalid JSON - {e}")
        all_errors.append(f"[FILE] Invalid JSON: {rules_file}")
        file_results['rules.json'] = 'FAIL'
    
    # Load and validate ALL ticket files
    global_ticket_ids = set()
    ticket_files = sorted(tickets_dir.glob('shift*.json'))
    
    if not ticket_files:
        print("No ticket files found in data/tickets/")
        all_errors.append("[FILE] No ticket files found")
    
    for ticket_file in ticket_files:
        print(f"Loading {ticket_file.name}...")
        try:
            tickets_data = load_json(ticket_file)
            ticket_errors = validate_tickets(tickets_data, toast_ids, ticket_file.name, global_ticket_ids)
            all_errors.extend(ticket_errors)
            ticket_count = len(tickets_data.get('tickets', []))
            print(f"  Found {ticket_count} tickets")
            file_results[ticket_file.name] = 'PASS' if not ticket_errors else 'FAIL'
        except FileNotFoundError:
            print(f"  ERROR: File not found!")
            all_errors.append(f"[FILE] Missing: {ticket_file}")
            file_results[ticket_file.name] = 'FAIL'
        except json.JSONDecodeError as e:
            print(f"  ERROR: Invalid JSON - {e}")
            all_errors.append(f"[FILE] Invalid JSON: {ticket_file}")
            file_results[ticket_file.name] = 'FAIL'
    
    # Print per-file summary
    print()
    print("-" * 60)
    print("Per-File Summary:")
    print("-" * 60)
    for filename, status in file_results.items():
        icon = "✓" if status == 'PASS' else "✗"
        print(f"  {icon} {filename}: {status}")
    
    # Print results
    print()
    print("=" * 60)
    
    if all_errors:
        print(f"FAIL - {len(all_errors)} error(s) found:")
        print("=" * 60)
        for error in all_errors:
            print(f"  ✗ {error}")
        print()
        sys.exit(1)
    else:
        print("PASS - All checks passed!")
        print("=" * 60)
        print()
        sys.exit(0)


if __name__ == '__main__':
    main()
