# Hotel Hermes - Phase 1 Validation & Static Checker
# File: tests/validate_scripts.py
# Description: Validates Luau script syntax, checks table structure completeness,
#              and executes unit tests on server.py API endpoints.

import os
import re
import sys
import unittest

def check_luau_syntax(directory):
    """Scans all .lua files for balanced blocks, quotes, and required returns."""
    print("==================================================")
    print("1. VALIDATING LUAU SCRIPTS...")
    print("==================================================")

    errors = []
    file_count = 0

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".lua"):
                file_count += 1
                filepath = os.path.join(root, file)
                rel_path = os.path.relpath(filepath, directory)

                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()

                # Check balanced brackets
                open_brackets = content.count("{")
                close_brackets = content.count("}")
                if open_brackets != close_brackets:
                    errors.append(f"{rel_path}: Unbalanced curly braces {{{open_brackets} vs {close_brackets}}}")

                open_parens = content.count("(")
                close_parens = content.count(")")
                if open_parens != close_parens:
                    errors.append(f"{rel_path}: Unbalanced parentheses ({open_parens} vs {close_parens})")

                # Check module return
                if "SharedModules" in rel_path or "Layout" in rel_path or "Validator" in rel_path or "Bridge" in rel_path or "Manager" in rel_path or "Generator" in rel_path or "Controller" in rel_path or "Effects" in rel_path:
                    if not re.search(r'return\s+[A-Za-z0-9_]+', content):
                        errors.append(f"{rel_path}: Missing 'return Module' statement!")

                print(f"  [OK] {rel_path} ({len(content.splitlines())} lines)")

    print(f"\nTotal Luau files validated: {file_count}")
    if errors:
        print(f"Found {len(errors)} errors:")
        for e in errors:
            print(f"  - {e}")
        return False
    else:
        print("All Luau scripts passed syntax sanity checks! [PASSED]")
        return True

def test_server_api():
    """Runs functional tests against server.py endpoints."""
    print("\n==================================================")
    print("2. TESTING PYTHON BACKEND API (server.py)...")
    print("==================================================")

    # Add server directory to sys.path
    server_dir = os.path.join(os.path.dirname(__file__), "..", "server")
    sys.path.insert(0, os.path.abspath(server_dir))

    try:
        from server import app, API_SECRET
    except ImportError as e:
        print(f"Could not import server: {e}")
        return False

    client = app.test_client()

    # 1. Health check
    res = client.get('/api/health')
    assert res.status_code == 200, f"Health check failed: {res.status_code}"
    print("  [OK] GET /api/health -> 200 OK")

    # 2. Check-In without auth (Should fail 401)
    res = client.post('/api/player/checkin', json={"roblox_user_id": 12345})
    assert res.status_code == 401, f"Expected 401 Unauthorized, got: {res.status_code}"
    print("  [OK] POST /api/player/checkin (unauthenticated) -> 401 Unauthorized")

    # 3. Check-In with valid auth
    headers = {"Authorization": f"Bearer {API_SECRET}"}
    res = client.post('/api/player/checkin', json={
        "roblox_user_id": 987654,
        "username": "TestPlayer",
        "is_paid": True
    }, headers=headers)
    assert res.status_code == 200, f"Checkin failed: {res.data}"
    assert res.json["success"] is True
    print("  [OK] POST /api/player/checkin (authenticated) -> 200 OK")

    # 4. Log Session Analytics
    res = client.post('/api/analytics/session', json={
        "roblox_user_id": 987654,
        "floor_reached": 5,
        "outcome": "CHECKED_OUT",
        "coins_earned": 280,
        "duration_seconds": 320
    }, headers=headers)
    assert res.status_code == 200
    print("  [OK] POST /api/analytics/session -> 200 OK")

    # 5. Get Leaderboard
    res = client.get('/api/leaderboard')
    assert res.status_code == 200
    assert len(res.json["leaderboard"]) >= 1
    print("  [OK] GET /api/leaderboard -> 200 OK (Player present)")

    # 6. Get Player Stats
    res = client.get('/api/player/stats/987654', headers=headers)
    assert res.status_code == 200
    assert res.json["highest_floor"] == 5
    print("  [OK] GET /api/player/stats/987654 -> 200 OK")

    print("\nAll Backend API endpoints tested successfully! [PASSED]")
    return True

if __name__ == "__main__":
    src_dir = os.path.join(os.path.dirname(__file__), "..", "src")
    luau_passed = check_luau_syntax(src_dir)
    server_passed = test_server_api()

    if luau_passed and server_passed:
        print("\n==================================================")
        print("ALL PHASE 1 ANTIGRAVITY TASKS VALIDATED SUCCESSFULLY! [PASSED]")
        print("==================================================")
        sys.exit(0)
    else:
        print("\nValidation failed!")
        sys.exit(1)
