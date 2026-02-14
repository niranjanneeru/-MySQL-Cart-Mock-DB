-- ============================================================
-- 08_seed_promotions.sql
-- Coupons + Coupon Usage
-- ============================================================
-- CP8: "Can you give me a discount?" — Diya must enforce eligibility.
-- Coupons have strict rules: user type, min order, category, expiry.
-- Diya cannot bend these rules or make exceptions.
--
-- COUPONS (8):
--   WELCOME100  — new users only, flat ₹100 off
--   SAVE500     — all users, flat ₹500 off on ₹2999+
--   KVPREMIUM   — premium only, flat ₹1000 off on ₹4999+
--   ELECTRO15   — 15% off electronics, max ₹2000
--   FASHION20   — 20% off fashion, max ₹500
--   SUMMER10    — future coupon (not yet active)
--   FREESHIP    — free shipping on ₹499+
--   EXPIRED50   — expired coupon (for testing)
--
-- COUPON USAGE (3):
--   Order 2:  Arjun used SAVE500
--   Order 13: Deepa used WELCOME100
--   Order 14: Sneha used KVPREMIUM ← BUG: she's not premium!
-- ============================================================

USE kvkart;

-- ============================================================
-- COUPONS
-- ============================================================

INSERT INTO coupons (coupon_id, code, description, discount_type, discount_value, min_order_amount, max_discount_amount, applicable_categories, applicable_user_type, usage_limit_total, usage_limit_per_user, times_used, valid_from, valid_until, is_active) VALUES

-- 1. WELCOME100: New user welcome offer
(1, 'WELCOME100',
 'Flat ₹100 off on your first order. Minimum order ₹499.',
 'flat', 100.00, 499.00, 100.00,
 NULL,       -- all categories
 'new',      -- new users only
 10000, 1,   -- 1 use per user, 10K total
 3421,
 '2024-01-01 00:00:00', '2025-12-31 23:59:59', TRUE),

-- 2. SAVE500: General savings coupon
(2, 'SAVE500',
 'Flat ₹500 off on orders above ₹2999. All users.',
 'flat', 500.00, 2999.00, 500.00,
 NULL,       -- all categories
 'all',      -- everyone
 5000, 2,    -- 2 uses per user
 2105,
 '2025-01-01 00:00:00', '2025-03-31 23:59:59', TRUE),

-- 3. KVPREMIUM: Premium members exclusive
(3, 'KVPREMIUM',
 'Flat ₹1000 off for KV Kart Premium members. Minimum order ₹4999.',
 'flat', 1000.00, 4999.00, 1000.00,
 NULL,       -- all categories
 'premium',  -- premium users ONLY
 2000, 1,
 890,
 '2025-01-01 00:00:00', '2025-06-30 23:59:59', TRUE),

-- 4. ELECTRO15: Electronics category discount
(4, 'ELECTRO15',
 '15% off on Electronics (mobiles, laptops, audio). Max discount ₹2000.',
 'percentage', 15.00, 1999.00, 2000.00,
 '1',         -- category_id 1 = Electronics (includes all children: 6,7,8,9)
 'all',
 3000, 1,
 1230,
 '2025-01-15 00:00:00', '2025-02-28 23:59:59', TRUE),

-- 5. FASHION20: Fashion category discount
(5, 'FASHION20',
 '20% off on Fashion (clothing, footwear, accessories). Max discount ₹500.',
 'percentage', 20.00, 999.00, 500.00,
 '2',         -- category_id 2 = Fashion (includes all children: 10-14)
 'all',
 5000, 2,
 1875,
 '2025-02-01 00:00:00', '2025-03-31 23:59:59', TRUE),

-- 6. SUMMER10: Future coupon (not yet active)
-- Teams' agents should recognize this is not yet valid
(6, 'SUMMER10',
 '10% off sitewide for summer sale. Max discount ₹300. Starts April 2025.',
 'percentage', 10.00, 599.00, 300.00,
 NULL,
 'all',
 NULL, 3,    -- unlimited total, 3 per user
 0,
 '2025-04-01 00:00:00', '2025-06-30 23:59:59', FALSE),

-- 7. FREESHIP: Free shipping coupon
(7, 'FREESHIP',
 'Free shipping on orders above ₹499. Waives standard shipping fee.',
 'flat', 49.00, 499.00, 49.00,
 NULL,
 'all',
 NULL, 5,    -- unlimited total, 5 per user
 4520,
 '2025-01-01 00:00:00', '2025-12-31 23:59:59', TRUE),

-- 8. EXPIRED50: Expired coupon (edge case for testing)
-- Agent should tell user this coupon is no longer valid
(8, 'EXPIRED50',
 'Flat ₹50 off. Minimum order ₹199. (Expired Dec 2024)',
 'flat', 50.00, 199.00, 50.00,
 NULL,
 'all',
 1000, 1,
 800,
 '2024-06-01 00:00:00', '2024-12-31 23:59:59', FALSE);


-- ============================================================
-- COUPON USAGE
-- ============================================================
-- Records of which users applied which coupons on which orders.
--
-- Usage 3 is the deliberate data inconsistency:
--   Sneha (user 7) is NOT a premium member
--   but she used KVPREMIUM on Order 14
--   This is a system bug teams can discover.
-- ============================================================

INSERT INTO coupon_usage (usage_id, coupon_id, user_id, order_id, discount_applied, used_at) VALUES

-- Arjun used SAVE500 on Order 2 (₹4,718 total, ₹500 off)
(1, 2, 1, 2, 500.00, '2025-01-25 18:00:00'),

-- Deepa used WELCOME100 on Order 13 (first order, ₹647 total, ₹100 off)
(2, 1, 13, 13, 100.00, '2025-02-10 15:00:00'),

-- Sneha used KVPREMIUM on Order 14 (₹5,309 total, ₹1000 off)
-- ⚠️ BUG: Sneha (user 7) has is_premium_member = FALSE
-- The system should have rejected this. Teams should catch this.
(3, 3, 7, 14, 1000.00, '2025-02-09 11:00:00');
