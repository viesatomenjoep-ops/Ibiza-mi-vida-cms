-- ============================================================
-- Ibiza mi vida — Migration 002: Featured Events
-- Managed via CMS. Drives the homepage featured events slider.
-- ============================================================

-- 1. Create table if it does not exist (with all columns and unified categories)
CREATE TABLE IF NOT EXISTS featured_events (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  title        TEXT NOT NULL,
  subtitle     TEXT,
  description  TEXT,
  image_url    TEXT NOT NULL,
  category     TEXT NOT NULL CHECK (category IN (
                 'boat-charter','club-ticket','boat-party',
                 'catamaran','formentera','car-rental','guestlist','drink-package',
                 'private-boat','vip-catamaran','formentera-boat','aftersun',
                 'free-discount','ibiza-tips','car-scooter'
               )),
  venue_name   TEXT,          -- Club or venue name (e.g. 'Pacha Ibiza')
  event_date   DATE,
  price_from   NUMERIC(10,2),
  ticket_price NUMERIC(10,2), -- Added in CMS update
  currency     TEXT DEFAULT 'EUR',
  badge_text   TEXT,          -- e.g. 'This Weekend', 'Selling Fast', 'New'
  cta_label    TEXT NOT NULL DEFAULT 'Book Now',
  cta_href     TEXT,          -- Internal route (e.g. '/club-tickets/pacha')
  booking_type TEXT NOT NULL DEFAULT 'whatsapp'
               CHECK (booking_type IN ('whatsapp','external_link','internal_link')),
  external_url TEXT,          -- Used when booking_type = 'external_link'
  sort_order   INTEGER DEFAULT 0,
  active       BOOLEAN DEFAULT TRUE,
  comm_viesa   NUMERIC(5,2) DEFAULT 75, -- Added in CMS update
  comm_simon   NUMERIC(5,2) DEFAULT 25  -- Added in CMS update
);

-- RLS
ALTER TABLE featured_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read" ON featured_events;
CREATE POLICY "Public read" ON featured_events FOR SELECT USING (active = true);

DROP POLICY IF EXISTS "Admin all" ON featured_events;
CREATE POLICY "Admin all" ON featured_events FOR ALL USING (auth.role() = 'authenticated');

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS featured_events_updated_at ON featured_events;
CREATE TRIGGER featured_events_updated_at
  BEFORE UPDATE ON featured_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- SEED DATA — 19 test events (15 clubs + 4 categories)
-- ============================================================

-- Note: In a fresh database, this inserts the 19 default events.
-- If the table already exists, you can comment this block out or let it run.
INSERT INTO featured_events
  (title, subtitle, image_url, category, venue_name, event_date, price_from, badge_text, cta_label, cta_href, booking_type, sort_order)
VALUES

-- ── CLUB EVENTS ─────────────────────────────────────────────

(
  'Cocoon with Sven Väth',
  'The legendary minimal techno night returns',
  'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&q=85',
  'club-ticket', 'Amnesia', '2026-07-15', 45,
  'Iconic Night', 'Get Tickets', '/club-tickets/amnesia', 'internal_link', 1
),
(
  'Flower Power',
  'Ibiza''s longest-running themed party',
  'https://images.unsplash.com/photo-1571266028243-e4d811c95a1f?w=800&q=85',
  'club-ticket', 'Pacha Ibiza', '2026-07-18', 35,
  'Every Friday', 'Get Tickets', '/club-tickets/pacha', 'internal_link', 2
),
(
  'Afterlife — Tale of Us',
  'Melodic techno under the stars',
  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=85',
  'club-ticket', 'Hi Ibiza', '2026-07-22', 60,
  'Selling Fast', 'Get Tickets', '/club-tickets/hi-ibiza', 'internal_link', 3
),
(
  'David Guetta — F*** Me I''m Famous',
  'The world''s biggest open-air pool party',
  'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=85',
  'club-ticket', 'Ushaia Ibiza', '2026-07-25', 55,
  'This Weekend', 'Get Tickets', '/club-tickets/ushaia', 'internal_link', 4
),
(
  'Circoloco',
  'Underground techno marathon from sunrise to sunset',
  'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&q=85',
  'club-ticket', 'Universe', '2026-08-01', 40,
  NULL, 'Get Tickets', '/club-tickets/universe', 'internal_link', 5
),
(
  'Pool Party & Foam Party',
  'Day-to-night pool madness',
  'https://images.unsplash.com/photo-1571266028243-e4d811c95a1f?w=800&q=85',
  'club-ticket', 'O Beach Ibiza', '2026-08-05', 30,
  'Family Favourite', 'Get Tickets', '/club-tickets/o-beach', 'internal_link', 6
),
(
  'Ibiza Rocks Weekend',
  'Live bands, DJs, and pool sessions',
  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=85',
  'club-ticket', 'Ibiza Rocks', '2026-08-08', 40,
  'Live Music', 'Get Tickets', '/club-tickets/ibiza-rocks', 'internal_link', 7
),
(
  'Water Party',
  'The most spectacular party venue in Ibiza',
  'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=85',
  'club-ticket', 'Es Paradis', '2026-08-12', 35,
  'Legendary', 'Get Tickets', '/club-tickets/es-paradis', 'internal_link', 8
),
(
  'Goodgreef Ibiza',
  'Hard house and trance classics',
  'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&q=85',
  'club-ticket', 'Eden Ibiza', '2026-08-15', 25,
  NULL, 'Get Tickets', '/club-tickets/eden', 'internal_link', 9
),
(
  'Sunset Sessions at Playa Soleil',
  'Chilled vibes, craft cocktails, and ocean views',
  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=85',
  'club-ticket', 'Playa Soleil', '2026-08-19', 20,
  'Free Entry Early', 'Get Tickets', '/club-tickets/playa-soleil', 'internal_link', 10
),
(
  'Full Moon Jungle Party',
  'Dance in the jungle under a full moon',
  'https://images.unsplash.com/photo-1571266028243-e4d811c95a1f?w=800&q=85',
  'club-ticket', 'Bam-Bu-Ku', '2026-08-22', 25,
  'Full Moon', 'Get Tickets', '/club-tickets/bam-bu-ku', 'internal_link', 11
),
(
  'Friday Night at Chinois',
  'Oriental glamour meets house music',
  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=85',
  'club-ticket', 'Chinois', '2026-08-26', 30,
  NULL, 'Get Tickets', '/club-tickets/chinois', 'internal_link', 12
),
(
  'Healing Festival at 528',
  'Conscious music, healing frequencies, good energy',
  'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=85',
  'club-ticket', '528 Ibiza', '2026-08-29', 35,
  'New', 'Get Tickets', '/club-tickets/528-ibiza', 'internal_link', 13
),
(
  'Underground Sessions at Swag',
  'Raw techno, no compromise',
  'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&q=85',
  'club-ticket', 'Swag Ibiza', '2026-09-02', 20,
  NULL, 'Get Tickets', '/club-tickets/swag-ibiza', 'internal_link', 14
),
(
  'Lío Cabaret Night',
  'Dinner, cabaret shows, and dancing until sunrise',
  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=85',
  'club-ticket', 'Lío Ibiza', '2026-09-05', 65,
  'Premium', 'Reserve Table', '/club-tickets/lio', 'internal_link', 15
),

-- ── EXPERIENCE / CATEGORY EVENTS ────────────────────────────

(
  'Exclusive Sunset Charter',
  'Private yacht · Custom route · From Es Vedrà to Formentera',
  'https://images.unsplash.com/photo-1540946485063-a40da27545f8?w=800&q=85',
  'boat-charter', NULL, NULL, 500,
  'Most Popular', 'Enquire Now', '/private-boat-charters', 'internal_link', 16
),
(
  'Ocean Festival Boat Party',
  'Sunset cruise · Live DJs · Open bar included',
  'https://images.unsplash.com/photo-1520759941054-c7a4e3fde7d3?w=800&q=85',
  'boat-party', NULL, '2026-07-20', 85,
  'Selling Fast', 'Book Now', '/boat-parties', 'internal_link', 17
),
(
  'VIP Sunset Catamaran',
  'Luxury sailing · Open bar · Catering · Swimming stops',
  'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=85',
  'catamaran', NULL, NULL, 120,
  NULL, 'Book Now', '/vip-catamaran', 'internal_link', 18
),
(
  'Formentera Full Day Trip',
  'Crystal water · White sand · The world''s most beautiful island',
  'https://images.unsplash.com/photo-1499678329028-101435549a4e?w=800&q=85',
  'formentera', NULL, NULL, 80,
  'Day Trip', 'Book Now', '/formentera-boat-trips', 'internal_link', 19
);

-- ============================================================
-- SAFE ALTERS — Updates existing tables without data loss
-- ============================================================

-- Ensure the new columns are added if the table already exists
ALTER TABLE featured_events ADD COLUMN IF NOT EXISTS comm_viesa NUMERIC(5,2) DEFAULT 75;
ALTER TABLE featured_events ADD COLUMN IF NOT EXISTS comm_simon NUMERIC(5,2) DEFAULT 25;
ALTER TABLE featured_events ADD COLUMN IF NOT EXISTS ticket_price NUMERIC(10,2);

-- Update check constraint to support all categories (both old and new styles)
ALTER TABLE featured_events DROP CONSTRAINT IF EXISTS featured_events_category_check;
ALTER TABLE featured_events ADD CONSTRAINT featured_events_category_check CHECK (category IN (
  'boat-charter','club-ticket','boat-party',
  'catamaran','formentera','car-rental','guestlist','drink-package',
  'private-boat','vip-catamaran','formentera-boat','aftersun',
  'free-discount','ibiza-tips','car-scooter'
));
