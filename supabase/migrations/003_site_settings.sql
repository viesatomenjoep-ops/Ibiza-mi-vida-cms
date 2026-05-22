-- ============================================================
-- Ibiza mi vida — Migration 003: Site Customization Settings
-- ============================================================

CREATE TABLE IF NOT EXISTS site_settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Seed with default values
INSERT INTO site_settings (key, value) VALUES
  ('font_family', 'Quicksand'),
  ('color_bg', '#0B0B0C'),
  ('color_gold', '#D4AF37'),
  ('color_accent', '#5B8CFF'),
  ('color_text', '#FFFFFF'),
  ('logo_url', 'logo.png')
ON CONFLICT (key) DO NOTHING;

-- RLS
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read settings" ON site_settings;
CREATE POLICY "Public read settings" ON site_settings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin all settings" ON site_settings;
CREATE POLICY "Admin all settings" ON site_settings FOR ALL USING (auth.role() = 'authenticated');
