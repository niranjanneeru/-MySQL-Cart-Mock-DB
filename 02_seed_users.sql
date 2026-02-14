-- ============================================================
-- 02_seed_users.sql
-- 15 Users + Addresses
-- ============================================================
-- User design rationale:
--   - Mix of premium (4) and regular (10) and suspended (1)
--   - Spread across Indian cities for delivery estimate diversity
--   - Mix of old accounts and brand new signups
--   - One suspended account (CP8: account_suspension policy)
--   - One deactivated account
-- ============================================================

USE kvkart;

INSERT INTO users (user_id, first_name, last_name, email, phone, date_of_birth, gender, account_status, is_premium_member, premium_expiry, created_at, last_login_at) VALUES
-- === PREMIUM MEMBERS (4) ===
(1,  'Arjun',    'Menon',      'arjun.menon@email.com',      '+919876543210', '1995-03-15', 'male',   'active',      TRUE,  '2026-03-15', '2024-06-01 10:00:00', '2025-02-10 09:30:00'),
(2,  'Vikram',   'Iyer',       'vikram.iyer@email.com',      '+919876543214', '1988-05-12', 'male',   'active',      TRUE,  '2026-06-01', '2023-11-20 12:00:00', '2025-02-10 08:00:00'),
(3,  'Arun',     'Thomas',     'arun.thomas@email.com',      '+919876543218', '1985-08-20', 'male',   'active',      TRUE,  '2025-08-20', '2023-08-20 08:00:00', '2025-02-09 22:00:00'),
(4,  'Nisha',    'Gupta',      'nisha.gupta@email.com',      '+919876543220', '1991-10-03', 'female', 'active',      TRUE,  '2025-12-31', '2024-02-14 09:00:00', '2025-02-10 10:15:00'),

-- === REGULAR ACTIVE MEMBERS (8) ===
(5,  'Priya',    'Sharma',     'priya.sharma@email.com',     '+919876543211', '1998-07-22', 'female', 'active',      FALSE, NULL,          '2024-08-15 14:00:00', '2025-02-09 18:45:00'),
(6,  'Rahul',    'Nair',       'rahul.nair@email.com',       '+919876543212', '1992-11-08', 'male',   'active',      FALSE, NULL,          '2024-01-10 08:00:00', '2025-02-10 11:00:00'),
(7,  'Sneha',    'Patel',      'sneha.patel@email.com',      '+919876543213', '2000-01-30', 'female', 'active',      FALSE, NULL,          '2025-01-05 16:00:00', '2025-02-08 20:15:00'),
(8,  'Ananya',   'Reddy',      'ananya.reddy@email.com',     '+919876543215', '1996-09-18', 'female', 'active',      FALSE, NULL,          '2024-12-01 09:00:00', '2025-02-07 15:30:00'),
(9,  'Meera',    'Joshi',      'meera.joshi@email.com',      '+919876543219', '2001-06-14', 'female', 'active',      FALSE, NULL,          '2025-01-20 13:00:00', '2025-02-10 07:45:00'),
(10, 'Rohan',    'Deshmukh',   'rohan.deshmukh@email.com',   '+919876543221', '1994-02-28', 'male',   'active',      FALSE, NULL,          '2024-09-10 11:00:00', '2025-02-09 14:20:00'),
(11, 'Fatima',   'Khan',       'fatima.khan@email.com',      '+919876543222', '1997-12-05', 'female', 'active',      FALSE, NULL,          '2024-07-22 16:30:00', '2025-02-08 09:00:00'),
(12, 'Siddharth','Rao',        'siddharth.rao@email.com',    '+919876543223', '1993-06-17', 'male',   'active',      FALSE, NULL,          '2024-05-01 10:00:00', '2025-02-10 12:30:00'),

-- === NEW USER (just signed up, 1) ===
(13, 'Deepa',    'Krishnan',   'deepa.krishnan@email.com',   '+919876543217', '1993-04-05', 'female', 'active',      FALSE, NULL,          '2025-02-01 10:00:00', '2025-02-10 12:00:00'),

-- === SUSPENDED ACCOUNT (1) — CP8: account_suspension policy ===
(14, 'Karthik',  'Suresh',     'karthik.suresh@email.com',   '+919876543216', '1990-12-25', 'male',   'suspended',   FALSE, NULL,          '2024-03-10 11:00:00', '2025-01-15 10:00:00'),

-- === DEACTIVATED ACCOUNT (1) ===
(15, 'Tanya',    'Bose',       'tanya.bose@email.com',       '+919876543224', '1999-03-11', 'female', 'deactivated', FALSE, NULL,          '2024-04-18 08:00:00', '2024-11-30 16:00:00');


-- ============================================================
-- ADDRESSES
-- ============================================================
-- Rationale:
--   - At least 1 address per user, power users have 2-3
--   - Cities spread across India for delivery_estimates coverage
--   - Pincodes are real Indian pincodes for realism
--   - Some users share a city (Kochi has 3 users — local deliveries)
-- ============================================================

INSERT INTO addresses (address_id, user_id, label, full_name, phone, address_line1, address_line2, city, state, pincode, is_default) VALUES

-- User 1: Arjun (Kochi) — 2 addresses: home + work
(1,  1,  'home', 'Arjun Menon',      '+919876543210', '42 MG Road, Panampilly Nagar',     'Near Lulu Mall',           'Kochi',       'Kerala',           '682036', TRUE),
(2,  1,  'work', 'Arjun Menon',      '+919876543210', 'KeyValue Systems, Infopark',       'Phase 2, Building 5',      'Kochi',       'Kerala',           '682042', FALSE),

-- User 2: Vikram (Chennai) — 2 addresses: home + parents
(3,  2,  'home',   'Vikram Iyer',    '+919876543214', '10 Anna Salai',                    'T Nagar',                  'Chennai',     'Tamil Nadu',       '600017', TRUE),
(4,  2,  'other',  'Vikram Iyer',    '+919876543214', '55 Cathedral Road',                'Gopalapuram',              'Chennai',     'Tamil Nadu',       '600086', FALSE),

-- User 3: Arun (Delhi) — 2 addresses
(5,  3,  'home', 'Arun Thomas',      '+919876543218', '3 Connaught Place',                'Block A',                  'New Delhi',   'Delhi',            '110001', TRUE),
(6,  3,  'work', 'Arun Thomas',      '+919876543218', 'Tower B, Cyber City',              'DLF Phase 2',             'Gurgaon',     'Haryana',          '122002', FALSE),

-- User 4: Nisha (Mumbai) — 2 addresses
(7,  4,  'home', 'Nisha Gupta',      '+919876543220', '14 Linking Road',                  'Bandra West',             'Mumbai',      'Maharashtra',      '400050', TRUE),
(8,  4,  'work', 'Nisha Gupta',      '+919876543220', 'WeWork, Enam Sambhav',             'BKC',                     'Mumbai',      'Maharashtra',      '400051', FALSE),

-- User 5: Priya (Bangalore) — 1 address
(9,  5,  'home', 'Priya Sharma',     '+919876543211', '15 Residency Road',                'Shanti Nagar',            'Bangalore',   'Karnataka',        '560025', TRUE),

-- User 6: Rahul (Kochi) — 2 addresses
(10, 6,  'home',  'Rahul Nair',      '+919876543212', '78 Warrior Road, Ernakulam',       NULL,                      'Kochi',       'Kerala',           '682016', TRUE),
(11, 6,  'other', 'Rahul Nair',      '+919876543212', 'Flat 301, Skyline Apartments',     'Kakkanad',                'Kochi',       'Kerala',           '682030', FALSE),

-- User 7: Sneha (Ahmedabad) — 1 address
(12, 7,  'home', 'Sneha Patel',      '+919876543213', '23 SG Highway',                    'Near Prahlad Nagar',      'Ahmedabad',   'Gujarat',          '380015', TRUE),

-- User 8: Ananya (Hyderabad) — 1 address
(13, 8,  'home', 'Ananya Reddy',     '+919876543215', '55 Jubilee Hills',                 'Road No 36',              'Hyderabad',   'Telangana',        '500033', TRUE),

-- User 9: Meera (Pune) — 1 address
(14, 9,  'home', 'Meera Joshi',      '+919876543219', '67 FC Road',                       'Deccan Gymkhana',         'Pune',        'Maharashtra',      '411004', TRUE),

-- User 10: Rohan (Bangalore) — 2 addresses
(15, 10, 'home', 'Rohan Deshmukh',   '+919876543221', '22 Koramangala 4th Block',         'Near Forum Mall',         'Bangalore',   'Karnataka',        '560034', TRUE),
(16, 10, 'work', 'Rohan Deshmukh',   '+919876543221', '8th Floor, Prestige Tech Park',    'Marathahalli',            'Bangalore',   'Karnataka',        '560103', FALSE),

-- User 11: Fatima (Jaipur) — 1 address
(17, 11, 'home', 'Fatima Khan',      '+919876543222', '12 MI Road',                       'Near Panch Batti',        'Jaipur',      'Rajasthan',        '302001', TRUE),

-- User 12: Siddharth (Kochi) — 1 address
(18, 12, 'home', 'Siddharth Rao',    '+919876543223', '19 Marine Drive',                  'Ernakulam',               'Kochi',       'Kerala',           '682031', TRUE),

-- User 13: Deepa (Kochi, new user) — 1 address
(19, 13, 'home', 'Deepa Krishnan',   '+919876543217', 'Flat 4B, Riviera Apartments',      'Aluva',                   'Kochi',       'Kerala',           '683101', TRUE),

-- User 14: Karthik (Bangalore, suspended) — 1 address
(20, 14, 'home', 'Karthik Suresh',   '+919876543216', '8 Brigade Road',                   NULL,                      'Bangalore',   'Karnataka',        '560001', TRUE),

-- User 15: Tanya (Kolkata, deactivated) — 1 address
(21, 15, 'home', 'Tanya Bose',       '+919876543224', '45 Park Street',                   'Near Flurys',             'Kolkata',     'West Bengal',      '700016', TRUE);
