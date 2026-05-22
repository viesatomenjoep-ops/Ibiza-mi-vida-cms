-- Supabase Migration 002: featured_events
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS featured_events (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  title        TEXT NOT NULL,
  subtitle     TEXT,
  description  TEXT,
  image_url    TEXT,
  category     TEXT NOT NULL CHECK (category IN (
                 'club-ticket','boat-party','private-boat',
                 'drink-package','guestlist','vip-catamaran',
                 'formentera-boat','aftersun','free-discount',
                 'ibiza-tips','car-scooter'
               )),
  venue_name   TEXT,
  event_date   DATE,
  price_from   NUMERIC(10,2),
  ticket_price NUMERIC(10,2),
  currency     TEXT DEFAULT 'EUR',
  badge_text   TEXT,
  cta_label    TEXT NOT NULL DEFAULT 'Book Now',
  cta_href     TEXT,
  booking_type TEXT NOT NULL DEFAULT 'whatsapp'
               CHECK (booking_type IN ('whatsapp','external_link','internal_link')),
  external_url TEXT,
  sort_order   INTEGER DEFAULT 0,
  active       BOOLEAN DEFAULT TRUE,
  comm_viesa   NUMERIC(5,2) DEFAULT 75,
  comm_simon   NUMERIC(5,2) DEFAULT 25
);

ALTER TABLE featured_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read"  ON featured_events FOR SELECT USING (active = true);
CREATE POLICY "Admin all"    ON featured_events FOR ALL USING (auth.role() = 'authenticated');

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER featured_events_updated_at
  BEFORE UPDATE ON featured_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- If table already exists, ensure the new commission and ticket price columns are added
ALTER TABLE featured_events ADD COLUMN IF NOT EXISTS comm_viesa NUMERIC(5,2) DEFAULT 75;
ALTER TABLE featured_events ADD COLUMN IF NOT EXISTS comm_simon NUMERIC(5,2) DEFAULT 25;
ALTER TABLE featured_events ADD COLUMN IF NOT EXISTS ticket_price NUMERIC(10,2);

