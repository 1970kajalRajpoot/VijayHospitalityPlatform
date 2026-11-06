CREATE TABLE IF NOT EXISTS dynamic_rules(
 id INTEGER PRIMARY KEY,
 category_id INTEGER REFERENCES room_categories(id) ON DELETE CASCADE,
 name TEXT NOT NULL,
 kind TEXT NOT NULL CHECK(kind IN('weekend','occupancy','last_minute','early_bird','long_stay','event')),
 dow TEXT,
 threshold INTEGER,
 start_date TEXT,
 end_date TEXT,
 pct INTEGER NOT NULL,
 priority INTEGER NOT NULL DEFAULT 0,
 active INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS ix_dynamic_rules_active ON dynamic_rules(active,category_id,priority);
CREATE TABLE IF NOT EXISTS site_media(
 id INTEGER PRIMARY KEY,
 kind TEXT NOT NULL CHECK(kind IN('slide','gallery','room')),
 property_id INTEGER REFERENCES properties(id) ON DELETE SET NULL,
 category_id INTEGER REFERENCES room_categories(id) ON DELETE SET NULL,
 title TEXT,
 caption TEXT,
 link_url TEXT,
 path TEXT NOT NULL,
 sort INTEGER NOT NULL DEFAULT 0,
 active INTEGER NOT NULL DEFAULT 1,
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 source_key TEXT UNIQUE
);
CREATE INDEX IF NOT EXISTS ix_site_media_kind ON site_media(kind,active,sort,id);
CREATE INDEX IF NOT EXISTS ix_site_media_category ON site_media(category_id,kind,active,sort);
