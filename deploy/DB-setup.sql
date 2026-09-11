-- ============================================================
-- SETUP DATABASE SA-MP Revitalize Roleplay
-- Jalankan file ini DULU via MySQL CLI / Workbench
-- GANTI 'GANTI_PASSWORD_KUAT' dengan password pilihanmu
-- ============================================================

CREATE DATABASE IF NOT EXISTS revitali_rp
  CHARACTER SET latin1
  COLLATE latin1_swedish_ci;

CREATE USER IF NOT EXISTS 'revitali'@'localhost'
  IDENTIFIED BY 'GANTI_PASSWORD_KUAT';

GRANT ALL PRIVILEGES ON revitali_rp.* TO 'revitali'@'localhost';
FLUSH PRIVILEGES;

-- Setelah itu, IMPORT skema (31 tabel) dengan perintah:
--   mysql -u revitali -p revitali_rp < revitali_rp.sql
-- (atau import lewat MySQL Workbench: Database > Restore from SQL File)
