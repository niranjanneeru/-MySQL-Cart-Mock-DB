-- ============================================================
-- 99_grant_permissions.sql
-- Grant diya user full access to kvkart database
-- ============================================================

USE kvkart;

-- Grant all privileges on kvkart to the diya user
GRANT ALL PRIVILEGES ON kvkart.* TO 'diya'@'%';
FLUSH PRIVILEGES;
