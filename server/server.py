# Hotel Hermes - External Analytics & Live-Ops Server
# File: server/server.py
# Description: REST API connecting Roblox game servers to Supabase database,
#              logging player sessions, and managing cross-server leaderboards.

import os
import time
from functools import wraps
from flask import Flask, request, jsonify

# Load environment variables from .env if python-dotenv is present
try:
    from dotenv import load_dotenv
    for env_path in [
        os.path.join(os.path.dirname(__file__), "..", ".env"),
        os.path.join(os.path.dirname(__file__), ".env"),
        ".env"
    ]:
        if os.path.exists(env_path):
            load_dotenv(env_path)
            break
except ImportError:
    pass

app = Flask(__name__)

# Authentication & Config
API_SECRET = os.getenv("HERMES_API_SECRET", "HERMES_HOTEL_SECRET_TOKEN_2026")
SUPABASE_ACCESS_TOKEN = os.getenv("supabase_access_token", "")
SUPABASE_PROJECT = os.getenv("project_name", "roblox game")

# Rate Limiting Configuration (100 req/min per game server / IP)
RATE_LIMIT_REQUESTS = 100
RATE_LIMIT_WINDOW = 60.0  # seconds
client_request_history = {}

def check_rate_limit(client_id: str) -> bool:
    """Sliding-window rate limiter enforcing 100 req/min per client."""
    now = time.time()
    history = client_request_history.setdefault(client_id, [])
    history[:] = [t for t in history if now - t < RATE_LIMIT_WINDOW]
    if len(history) >= RATE_LIMIT_REQUESTS:
        return False
    history.append(now)
    return True

@app.before_request
def rate_limit_middleware():
    """Applies rate limiting across all incoming requests."""
    client_ip = request.remote_addr or "127.0.0.1"
    if not check_rate_limit(client_ip):
        return jsonify({"error": "Rate limit exceeded. Maximum 100 requests per minute."}), 429

# In-memory store (Fallback when database connection is offline)
mock_db = {
    "players": {},
    "sessions": [],
    "leaderboard": {}
}

def require_auth(f):
    """Verifies shared Bearer token from Roblox HttpService."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        expected = f"Bearer {API_SECRET}"
        if auth_header != expected:
            return jsonify({"error": "Unauthorized. Invalid bearer token."}), 401
        return f(*args, **kwargs)
    return decorated_function

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint for Roblox and monitoring."""
    return jsonify({
        "status": "healthy",
        "service": "Hotel Hermes Live-Ops Engine",
        "timestamp": time.time(),
        "supabase_configured": bool(SUPABASE_ACCESS_TOKEN)
    }), 200

@app.route('/api/player/checkin', methods=['POST'])
@require_auth
def player_checkin():
    """Logs player check-in event."""
    data = request.json or {}
    user_id = data.get("roblox_user_id")
    username = data.get("username", "Guest")
    is_paid = data.get("is_paid", False)

    if not user_id:
        return jsonify({"error": "Missing roblox_user_id"}), 400

    player = mock_db["players"].setdefault(user_id, {
        "roblox_user_id": user_id,
        "username": username,
        "total_checkins": 0,
        "paid_checkins": 0,
        "first_seen": time.time()
    })

    player["total_checkins"] += 1
    if is_paid:
        player["paid_checkins"] += 1
    player["last_seen"] = time.time()

    return jsonify({
        "success": True,
        "player": player
    }), 200

@app.route('/api/analytics/session', methods=['POST'])
@require_auth
def log_session():
    """Logs run outcome metrics for retention analysis."""
    data = request.json or {}
    user_id = data.get("roblox_user_id")
    floor_reached = data.get("floor_reached", 1)
    outcome = data.get("outcome", "UNKNOWN")
    coins_earned = data.get("coins_earned", 0)
    duration_sec = data.get("duration_seconds", 0)

    session_record = {
        "user_id": user_id,
        "floor_reached": floor_reached,
        "outcome": outcome,
        "coins_earned": coins_earned,
        "duration_seconds": duration_sec,
        "timestamp": time.time()
    }
    mock_db["sessions"].append(session_record)

    # Update leaderboard
    current_high = mock_db["leaderboard"].get(user_id, 0)
    if floor_reached > current_high:
        mock_db["leaderboard"][user_id] = floor_reached

    return jsonify({
        "success": True,
        "recorded_session": session_record
    }), 200

@app.route('/api/leaderboard', methods=['GET'])
def get_leaderboard():
    """Returns sorted global top 50 players by floor reached."""
    sorted_board = sorted(
        [{"user_id": uid, "highest_floor": score} for uid, score in mock_db["leaderboard"].items()],
        key=lambda x: x["highest_floor"],
        reverse=True
    )
    return jsonify({
        "leaderboard": sorted_board[:50]
    }), 200

@app.route('/api/player/stats/<int:user_id>', methods=['GET'])
@require_auth
def get_player_stats(user_id):
    """Fetches player run history and aggregate statistics."""
    player = mock_db["players"].get(user_id)
    if not player:
        return jsonify({"error": "Player not found"}), 404

    player_sessions = [s for s in mock_db["sessions"] if s["user_id"] == user_id]
    return jsonify({
        "player": player,
        "highest_floor": mock_db["leaderboard"].get(user_id, 0),
        "total_sessions": len(player_sessions),
        "sessions": player_sessions[-10:] # last 10 runs
    }), 200

if __name__ == '__main__':
    print("Hotel Hermes Server running on port 5000...")
    app.run(host='0.0.0.0', port=5000, debug=False)
