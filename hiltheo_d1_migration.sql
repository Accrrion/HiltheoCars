-- Hiltheo Synergy — Cloudflare D1 initial migration
-- Generated from the uploaded project.
--
-- IMPORTANT: This migration creates the persistent schema and seeds the
-- 15 vehicle records currently hard-coded in src/App.jsx. The current
-- Express backend has no persistent user database; its users array is empty.
-- No user records or passwords are fabricated here.
--
-- Run against a NEW/EMPTY D1 database first.

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT,
  google_id TEXT UNIQUE,
  picture_url TEXT,
  auth_type TEXT NOT NULL DEFAULT 'local' CHECK (auth_type IN ('local','google')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','deleted')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE IF NOT EXISTS permissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE IF NOT EXISTS admins (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  role_id INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','revoked')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS role_permissions (
  role_id INTEGER NOT NULL,
  permission_id INTEGER NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS admin_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen_at TEXT,
  ip_address TEXT,
  user_agent TEXT,
  revoked_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vehicles (
  id INTEGER PRIMARY KEY,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  price TEXT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  listed_date TEXT,
  image_url TEXT,
  engine TEXT,
  power TEXT,
  acceleration TEXT,
  transmission TEXT,
  status TEXT NOT NULL DEFAULT 'Available' CHECK (status IN ('Available','Reserved','Sold','Unavailable')),
  description TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  name TEXT,
  email TEXT,
  subject TEXT,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread','read','archived')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id TEXT PRIMARY KEY,
  admin_id TEXT,
  action TEXT NOT NULL,
  target_type TEXT,
  target_id TEXT,
  metadata TEXT,
  ip_address TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);
CREATE INDEX IF NOT EXISTS idx_vehicles_make_model ON vehicles(make, model);
CREATE INDEX IF NOT EXISTS idx_messages_status ON messages(status);
CREATE INDEX IF NOT EXISTS idx_admin_sessions_user ON admin_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_sessions_expires ON admin_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_admin ON audit_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at);

-- Default roles.
INSERT INTO roles (id, name, description) VALUES
  (1, 'super_admin', 'Full administrative access'),
  (2, 'inventory_admin', 'Manage vehicle inventory'),
  (3, 'support_admin', 'Manage users and customer messages')
ON CONFLICT(id) DO NOTHING;

-- Default permissions.
INSERT INTO permissions (id, name, description) VALUES
  (1, 'dashboard.view', 'View admin dashboard'),
  (2, 'vehicles.view', 'View vehicles'),
  (3, 'vehicles.create', 'Create vehicles'),
  (4, 'vehicles.update', 'Update vehicles'),
  (5, 'vehicles.delete', 'Delete vehicles'),
  (6, 'users.view', 'View users'),
  (7, 'users.update', 'Update users'),
  (8, 'messages.view', 'View customer messages'),
  (9, 'messages.update', 'Update customer messages'),
  (10, 'settings.manage', 'Manage site settings'),
  (11, 'admins.manage', 'Manage administrators'),
  (12, 'audit.view', 'View audit logs')
ON CONFLICT(id) DO NOTHING;

-- Super admin gets every permission.
INSERT OR IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

-- Inventory admin permissions.
INSERT OR IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE name IN (
  'dashboard.view','vehicles.view','vehicles.create','vehicles.update','vehicles.delete'
);

-- Support admin permissions.
INSERT OR IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE name IN (
  'dashboard.view','users.view','users.update','messages.view','messages.update'
);

-- Existing public inventory from src/App.jsx.
-- These are the actual 15 hard-coded catalog records found in the uploaded project.
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (1, 'Mercedes-Benz', 'S-Class S 580 4MATIC', 2023, '$125,000', 'USD', 'Jun 11, 2024', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800&q=80', '4.0L V8 Biturbo', '496 hp', '0-60 in 4.4s', '9-Speed Automatic', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (2, 'BMW', '7 Series 760i xDrive', 2024, '$140,000', 'USD', 'Jun 9, 2024', 'https://images.unsplash.com/photo-1520031441872-265e4ff70366?w=800&q=80', '4.4L V8 TwinPower', '536 hp', '0-60 in 4.1s', '8-Speed Sport Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (3, 'Audi', 'Q8 Prestige 55 TFSI', 2023, '$95,000', 'USD', 'Jun 10, 2024', 'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=800&q=80', '3.0L V6 TFSI', '335 hp', '0-60 in 5.6s', '8-Speed Tiptronic', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (4, 'Tesla', 'Model S Plaid', 2023, '$89,000', 'USD', 'Jun 12, 2024', 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800&q=80', 'Electric Tri-Motor', '1,020 hp', '0-60 in 1.99s', 'Single-Speed', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (5, 'Porsche', 'Panamera 4S', 2024, '$105,000', 'USD', 'Jun 8, 2024', 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?w=800&q=80', '2.9L V6 Twin-Turbo', '443 hp', '0-60 in 4.1s', '8-Speed PDK', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (6, 'Lamborghini', 'Huracan EVO', 2023, '$230,000', 'USD', 'Jun 7, 2024', 'https://images.unsplash.com/photo-1519245659620-e859806a8d3b?w=800&q=80', '5.2L V10', '631 hp', '0-60 in 2.9s', '7-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (7, 'Ferrari', '488 GTB', 2022, '$285,000', 'USD', 'Jun 6, 2024', 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800&q=80', '3.9L V8 Twin-Turbo', '661 hp', '0-60 in 3.0s', '7-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (8, 'Range Rover', 'Sport Dynamic', 2024, '$95,000', 'USD', 'Jun 5, 2024', 'https://images.unsplash.com/photo-1606220838315-056192d5e927?w=800&q=80', '3.0L Inline-6', '395 hp', '0-60 in 5.3s', '8-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (9, 'Lexus', 'LS 500', 2023, '$78,000', 'USD', 'Jun 4, 2024', 'https://images.unsplash.com/photo-1626078436812-e869e4d60822?w=800&q=80', '3.4L V6 Twin-Turbo', '416 hp', '0-60 in 4.6s', '10-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (10, 'Bentley', 'Continental GT', 2024, '$210,000', 'USD', 'Jun 3, 2024', 'https://images.unsplash.com/photo-1563720223185-11003d70e89b?w=800&q=80', '4.0L V8 Twin-Turbo', '542 hp', '0-60 in 3.9s', '8-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (11, 'Rolls Royce', 'Ghost', 2023, '$340,000', 'USD', 'Jun 2, 2024', 'https://images.unsplash.com/photo-1631295868223-63265b40d9e4?w=800&q=80', '6.75L V12', '563 hp', '0-60 in 4.8s', '8-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (12, 'Aston Martin', 'DB11', 2022, '$205,000', 'USD', 'Jun 1, 2024', 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800&q=80', '4.0L V8 Twin-Turbo', '503 hp', '0-60 in 3.9s', '8-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (13, 'Maserati', 'Quattroporte', 2023, '$145,000', 'USD', 'May 31, 2024', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800&q=80', '3.0L V6 Twin-Turbo', '424 hp', '0-60 in 4.8s', '8-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (14, 'Cadillac', 'Escalade Platinum', 2024, '$105,000', 'USD', 'May 30, 2024', 'https://images.unsplash.com/photo-1632823469850-891afbc0b5cb?w=800&q=80', '6.2L V8', '420 hp', '0-60 in 5.9s', '10-Speed Auto', 'Available');
INSERT INTO vehicles (id, make, model, year, price, currency, listed_date, image_url, engine, power, acceleration, transmission, status) VALUES (15, 'Jaguar', 'F-Type R', 2023, '$75,000', 'USD', 'May 29, 2024', 'https://images.unsplash.com/photo-1611659536267-e76951194f3b?w=800&q=80', '5.0L V8 Supercharged', '575 hp', '0-60 in 3.5s', '8-Speed Auto', 'Available');

COMMIT;
