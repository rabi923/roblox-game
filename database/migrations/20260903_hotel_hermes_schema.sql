-- Hotel Hermes Master Database Schema Migration
-- Applied to Supabase Project: obxymjtkwjbrqwcslmpk

-- 1. Players Table
CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    roblox_user_id BIGINT UNIQUE NOT NULL,
    username TEXT NOT NULL,
    first_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
    total_checkins INT NOT NULL DEFAULT 0,
    total_robux_spent INT NOT NULL DEFAULT 0,
    highest_floor INT NOT NULL DEFAULT 0,
    total_play_time_seconds INT NOT NULL DEFAULT 0
);

-- 2. Game Sessions Table
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at TIMESTAMPTZ,
    floors_cleared INT NOT NULL DEFAULT 0,
    highest_floor_this_session INT NOT NULL DEFAULT 0,
    death_floor INT,
    death_entity TEXT,
    robux_spent INT NOT NULL DEFAULT 0,
    hotel_coins_earned INT NOT NULL DEFAULT 0
);

-- 3. Global Leaderboard Table
CREATE TABLE IF NOT EXISTS leaderboard (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID UNIQUE NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    username TEXT NOT NULL,
    highest_floor INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Live Game Events Table
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_name TEXT NOT NULL,
    event_type TEXT NOT NULL,
    config_json JSONB DEFAULT '{}'::jsonb,
    starts_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ends_at TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT true
);

-- 5. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_leaderboard_highest_floor ON leaderboard(highest_floor DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_player_started ON sessions(player_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_players_roblox_user_id ON players(roblox_user_id);

-- 6. Row Level Security (RLS)
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies
DROP POLICY IF EXISTS "Public read leaderboard" ON leaderboard;
CREATE POLICY "Public read leaderboard" ON leaderboard
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read events" ON events;
CREATE POLICY "Public read events" ON events
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow read players" ON players;
CREATE POLICY "Allow read players" ON players
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow write players" ON players;
CREATE POLICY "Allow write players" ON players
    FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow write sessions" ON sessions;
CREATE POLICY "Allow write sessions" ON sessions
    FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow write leaderboard" ON leaderboard;
CREATE POLICY "Allow write leaderboard" ON leaderboard
    FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow write events" ON events;
CREATE POLICY "Allow write events" ON events
    FOR ALL USING (true) WITH CHECK (true);
