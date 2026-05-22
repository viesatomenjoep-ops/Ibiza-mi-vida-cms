-- ============================================================
-- Ibiza mi vida — Migration 004: Page Contents Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS page_contents (
  page_name   TEXT PRIMARY KEY, -- 'homepage', 'club-ticket', 'boat-party', etc.
  hero_title  TEXT,
  hero_sub    TEXT,
  description TEXT,
  cta_text    TEXT,
  hero_img    TEXT,
  logo_url    TEXT,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed with initial default homepage & category texts
INSERT INTO page_contents (page_name, hero_title, hero_sub, description, cta_text, hero_img, logo_url) VALUES
  ('homepage', 'Experience the Real Ibiza', 'Your ultimate guide to Ibiza nightlife, boat parties & more', 'Discover the best of Ibiza with Ibiza Mi Vida. From legendary club nights at Amnesia and Pacha to private yacht charters and day trips to Formentera — we bring you the full Ibiza experience.', 'Explore Events', 'hero.jpg', 'logo.png'),
  ('club-ticket', 'Club Tickets', 'Buy tickets for the best clubs in Ibiza', 'Get guaranteed entry to Pacha, Amnesia, Hï, Ushuaïa and more.', 'Get Tickets', 'clubs.jpg', 'logo.png'),
  ('boat-party', 'Boat Parties', 'The wildest parties on the Mediterranean', 'Dance to world-class DJs under the Ibiza sun.', 'Book Boat Party', 'boats.jpg', 'logo.png')
ON CONFLICT (page_name) DO NOTHING;

-- RLS
ALTER TABLE page_contents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read page content" ON page_contents;
CREATE POLICY "Public read page content" ON page_contents FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin all page content" ON page_contents;
CREATE POLICY "Admin all page content" ON page_contents FOR ALL USING (auth.role() = 'authenticated');
