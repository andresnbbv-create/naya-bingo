-- ============================================================
-- NAYA HOMES BINGO — DATABASE SETUP
-- Run this entire script in Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS reservations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reservation_number TEXT UNIQUE NOT NULL,
  last_name TEXT,
  guest_name TEXT,
  property_name TEXT,
  region TEXT,
  check_in DATE,
  check_out DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_reservations_number ON reservations(reservation_number);

CREATE TABLE IF NOT EXISTS bingo_players (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  reservation_number TEXT,
  check_in_date DATE,
  region TEXT,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_bingo BOOLEAN DEFAULT FALSE,
  activities_completed INT DEFAULT 0,
  photos_submitted INT DEFAULT 0,
  gift_sent BOOLEAN DEFAULT FALSE,
  gift_sent_at TIMESTAMPTZ,
  bear_token TEXT
);
CREATE INDEX IF NOT EXISTS idx_bingo_players_started ON bingo_players(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_bingo_players_reservation ON bingo_players(reservation_number);

CREATE TABLE IF NOT EXISTS bingo_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reservation_id UUID REFERENCES reservations(id),
  session_token TEXT,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_bingo BOOLEAN DEFAULT FALSE,
  reward_approved BOOLEAN DEFAULT FALSE,
  reward_approved_at TIMESTAMPTZ,
  reward_notes TEXT
);

CREATE TABLE IF NOT EXISTS completed_activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES bingo_sessions(id),
  activity_index INT,
  activity_name TEXT,
  photo_url TEXT,
  completed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bingo_logins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  check_in_date DATE,
  region TEXT,
  logged_in_at TIMESTAMPTZ DEFAULT NOW(),
  user_agent TEXT
);
CREATE INDEX IF NOT EXISTS idx_bingo_logins_at ON bingo_logins(logged_in_at DESC);

CREATE TABLE IF NOT EXISTS bingo_page_views (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  viewed_at TIMESTAMPTZ DEFAULT NOW(),
  user_agent TEXT
);
CREATE INDEX IF NOT EXISTS idx_bingo_views_at ON bingo_page_views(viewed_at DESC);

-- Token auto-generation trigger
CREATE OR REPLACE FUNCTION generate_naya_token()
RETURNS TRIGGER AS $$
DECLARE
  words1 TEXT[] := ARRAY['PALM','OCEAN','MARINA','MALECON','SAND','SUN','BAHIA','BANDERAS'];
  words2 TEXT[] := ARRAY['SUNSET','BEACH','WAVE','TROPIC','BREEZE','PARADISE','RIVIERA','NAYARIT'];
  num TEXT;
BEGIN
  IF NEW.bear_token IS NULL OR NEW.bear_token = '' THEN
    num := LPAD(FLOOR(RANDOM() * 900 + 100)::TEXT, 3, '0');
    NEW.bear_token := words1[FLOOR(RANDOM() * 8 + 1)] || '-' || words2[FLOOR(RANDOM() * 8 + 1)] || '-' || num;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_naya_token ON bingo_players;
CREATE TRIGGER trigger_naya_token
BEFORE INSERT OR UPDATE ON bingo_players
FOR EACH ROW EXECUTE FUNCTION generate_naya_token();

-- RLS Policies
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bingo_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE bingo_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE completed_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE bingo_logins ENABLE ROW LEVEL SECURITY;
ALTER TABLE bingo_page_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_read_players" ON bingo_players FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_players" ON bingo_players FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_players" ON bingo_players FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_read_logins" ON bingo_logins FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_logins" ON bingo_logins FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_read_views" ON bingo_page_views FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_views" ON bingo_page_views FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_read_reservations" ON reservations FOR SELECT TO anon USING (true);

SELECT 'Naya Bingo database setup complete!' AS status;
