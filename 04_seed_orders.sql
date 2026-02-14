-- ============================================================
-- 04_seed_orders.sql
-- Orders + Order Items
-- ============================================================
-- 25 orders across 13 users (user 14=suspended, 15=deactivated skip new orders)
--
-- STATUS DISTRIBUTION:
--   pending           : 1   (Order 25)
--   confirmed         : 2   (Orders 13, 17)
--   processing        : 2   (Orders 14, 18)  ← cancellable
--   shipped           : 3   (Orders 8, 15, 19) ← NOT cancellable (CP7 trap)
--   out_for_delivery  : 2   (Orders 16, 20)
--   delivered         : 10  (Orders 1,2,3,4,5,6,7,9,10,11)
--   cancelled         : 2   (Orders 12, 21)
--   return_requested  : 1   (Order 22)
--   returned          : 1   (Order 23)
--   failed            : 1   (Order 24)
--                     ----
--   TOTAL             : 25
--
-- KEY SCENARIOS BAKED IN:
--   Order 3:  Delivered Jan 20 → within 7-day return window if today ~Feb 10? No, outside.
--   Order 9:  Delivered Feb 7  → within 7-day return window ✓
--   Order 8:  Shipped          → user tries to cancel → CP7 fail scenario
--   Order 15: Shipped          → Ananya can't cancel (CP7)
--   Order 14: Processing       → Sneha can still cancel (CP5)
--   Order 18: Processing       → Arjun can still cancel (CP5)
--   Order 22: Delivered Feb 5, return requested Feb 8 → within window ✓
--   Order 23: Returned + refund completed
--   Order 24: Failed delivery (Rahul wasn't home)
--   Order 25: Pending COD, just placed
--   Orders 1,2,18: Arjun has 3+ orders → "how many orders did I place?"
--   Order 6:  Multi-item order (3 items)
--   Order 10: Multi-item order (2 items)
--
-- PAYMENT METHOD SPREAD:
--   upi: 8, credit_card: 5, debit_card: 3, net_banking: 2,
--   wallet: 2, cod: 3
-- ============================================================

USE kvkart;

INSERT INTO orders (order_id, order_number, user_id, shipping_address_id, order_status, subtotal, shipping_fee, discount_amount, tax_amount, total_amount, coupon_code, payment_method, payment_status, is_cancellable, cancellation_reason, cancelled_at, placed_at, confirmed_at, shipped_at, delivered_at, notes) VALUES

-- =============================================
-- DELIVERED ORDERS (10)
-- =============================================

-- Order 1: Arjun — delivered phone, happy path, Jan 15
(1,  'KV-20250115-0001', 1, 1, 'delivered',
     21999.00, 0.00, 0.00, 3960.00, 25959.00,
     NULL, 'upi', 'paid', FALSE,
     NULL, NULL,
     '2025-01-15 10:30:00', '2025-01-15 10:31:00', '2025-01-16 14:00:00', '2025-01-18 11:00:00',
     NULL),

-- Order 2: Arjun — delivered, used SAVE500 coupon, Jan 25
(2,  'KV-20250125-0002', 1, 2, 'delivered',
     4498.00, 0.00, 500.00, 720.00, 4718.00,
     'SAVE500', 'credit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-01-25 18:00:00', '2025-01-25 18:01:00', '2025-01-26 09:00:00', '2025-01-28 16:00:00',
     NULL),

-- Order 3: Vikram — delivered laptop, high value, Jan 10
(3,  'KV-20250110-0003', 2, 3, 'delivered',
     64999.00, 0.00, 0.00, 11700.00, 76699.00,
     NULL, 'net_banking', 'paid', FALSE,
     NULL, NULL,
     '2025-01-10 08:00:00', '2025-01-10 08:01:00', '2025-01-11 09:00:00', '2025-01-14 15:00:00',
     NULL),

-- Order 4: Vikram — delivered yoga mat, small order, Jan 20
(4,  'KV-20250120-0004', 2, 3, 'delivered',
     999.00, 49.00, 0.00, 189.00, 1237.00,
     NULL, 'upi', 'paid', FALSE,
     NULL, NULL,
     '2025-01-20 10:00:00', '2025-01-20 10:01:00', '2025-01-21 09:00:00', '2025-01-23 14:00:00',
     NULL),

-- Order 5: Sneha — delivered shirt, Jan 30, outside return window
(5,  'KV-20250130-0005', 7, 12, 'delivered',
     1599.00, 49.00, 0.00, 297.00, 1945.00,
     NULL, 'upi', 'paid', FALSE,
     NULL, NULL,
     '2025-01-30 15:00:00', '2025-01-30 15:01:00', '2025-01-31 10:00:00', '2025-02-04 12:00:00',
     NULL),

-- Order 6: Arun — delivered multi-item order (3 items), Jan 18
(6,  'KV-20250118-0006', 3, 5, 'delivered',
     4297.00, 0.00, 0.00, 774.00, 5071.00,
     NULL, 'credit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-01-18 09:00:00', '2025-01-18 09:01:00', '2025-01-19 08:00:00', '2025-01-24 11:00:00',
     NULL),

-- Order 7: Ananya — delivered denim jacket, Jan 28
(7,  'KV-20250128-0007', 8, 13, 'delivered',
     2499.00, 0.00, 0.00, 450.00, 2949.00,
     NULL, 'credit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-01-28 14:00:00', '2025-01-28 14:01:00', '2025-01-29 11:00:00', '2025-02-01 10:00:00',
     NULL),

-- Order 9: Rohan — delivered watch, Feb 3, WITHIN 7-day return window
(9,  'KV-20250201-0009', 10, 15, 'delivered',
     2999.00, 0.00, 0.00, 540.00, 3539.00,
     NULL, 'debit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-02-01 11:00:00', '2025-02-01 11:01:00', '2025-02-02 09:00:00', '2025-02-05 16:00:00',
     NULL),

-- Order 10: Fatima — delivered multi-item (kurti + sunglasses), Jan 25
(10, 'KV-20250125-0010', 11, 17, 'delivered',
     2598.00, 0.00, 0.00, 468.00, 3066.00,
     NULL, 'upi', 'paid', FALSE,
     NULL, NULL,
     '2025-01-25 12:00:00', '2025-01-25 12:01:00', '2025-01-26 10:00:00', '2025-01-31 14:00:00',
     NULL),

-- Order 11: Siddharth — delivered resistance bands, Feb 1, within return window
(11, 'KV-20250201-0011', 12, 18, 'delivered',
     749.00, 49.00, 0.00, 144.00, 942.00,
     NULL, 'cod', 'paid', FALSE,
     NULL, NULL,
     '2025-02-01 14:00:00', '2025-02-01 14:01:00', '2025-02-02 08:00:00', '2025-02-05 11:00:00',
     NULL),

-- =============================================
-- CANCELLED ORDERS (2)
-- =============================================

-- Order 12: Rahul — cancelled before shipping (CP5 happy path)
(12, 'KV-20250201-0012', 6, 10, 'cancelled',
     7499.00, 0.00, 0.00, 1350.00, 8849.00,
     NULL, 'upi', 'refunded', FALSE,
     'Changed my mind, found better price elsewhere', '2025-02-01 16:00:00',
     '2025-02-01 11:00:00', '2025-02-01 11:01:00', NULL, NULL,
     NULL),

-- Order 21: Nisha — cancelled COD order before shipping
(21, 'KV-20250205-0021', 4, 7, 'cancelled',
     1199.00, 49.00, 0.00, 225.00, 1473.00,
     NULL, 'cod', 'pending', FALSE,
     'Ordered by mistake', '2025-02-05 14:00:00',
     '2025-02-05 10:00:00', '2025-02-05 10:01:00', NULL, NULL,
     NULL),

-- =============================================
-- CONFIRMED (waiting to be processed) (2)
-- =============================================

-- Order 13: Deepa — first order, used WELCOME100, confirmed
(13, 'KV-20250210-0013', 13, 19, 'confirmed',
     599.00, 49.00, 100.00, 99.00, 647.00,
     'WELCOME100', 'upi', 'paid', TRUE,
     NULL, NULL,
     '2025-02-10 15:00:00', '2025-02-10 15:01:00', NULL, NULL,
     'First order — new user'),

-- Order 17: Priya — confirmed, COD, cancellable
(17, 'KV-20250210-0017', 5, 9, 'confirmed',
     1099.00, 49.00, 0.00, 207.00, 1355.00,
     NULL, 'cod', 'pending', TRUE,
     NULL, NULL,
     '2025-02-10 20:00:00', '2025-02-10 20:01:00', NULL, NULL,
     NULL),

-- =============================================
-- PROCESSING (cancellable) (2)
-- =============================================

-- Order 14: Sneha — processing air fryer, used KVPREMIUM coupon
-- NOTE: Sneha (user 7) is NOT premium — this is a data inconsistency
-- teams can discover. The coupon should have been rejected.
(14, 'KV-20250209-0014', 7, 12, 'processing',
     5499.00, 0.00, 1000.00, 810.00, 5309.00,
     'KVPREMIUM', 'wallet', 'paid', TRUE,
     NULL, NULL,
     '2025-02-09 11:00:00', '2025-02-09 11:01:00', NULL, NULL,
     NULL),

-- Order 18: Arjun — processing, multi-item fitness order, cancellable
(18, 'KV-20250210-0018', 1, 1, 'processing',
     1748.00, 0.00, 0.00, 315.00, 2063.00,
     NULL, 'wallet', 'paid', TRUE,
     NULL, NULL,
     '2025-02-10 08:00:00', '2025-02-10 08:01:00', NULL, NULL,
     NULL),

-- =============================================
-- SHIPPED (not cancellable — CP7 trap) (3)
-- =============================================

-- Order 8: Priya — shipped, in transit to Bangalore
(8,  'KV-20250207-0008', 5, 9, 'shipped',
     3499.00, 49.00, 0.00, 639.00, 4187.00,
     NULL, 'debit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-02-07 12:00:00', '2025-02-07 12:01:00', '2025-02-08 10:00:00', NULL,
     NULL),

-- Order 15: Ananya — shipped, wants to cancel but can't (CP7)
(15, 'KV-20250205-0015', 8, 13, 'shipped',
     1899.00, 49.00, 0.00, 351.00, 2299.00,
     NULL, 'upi', 'paid', FALSE,
     NULL, NULL,
     '2025-02-05 16:00:00', '2025-02-05 16:01:00', '2025-02-06 14:00:00', NULL,
     NULL),

-- Order 19: Nisha — shipped, premium user, en route to Mumbai
(19, 'KV-20250208-0019', 4, 7, 'shipped',
     2799.00, 0.00, 0.00, 504.00, 3303.00,
     NULL, 'credit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-02-08 09:00:00', '2025-02-08 09:01:00', '2025-02-09 08:00:00', NULL,
     NULL),

-- =============================================
-- OUT FOR DELIVERY (2)
-- =============================================

-- Order 16: Meera — out for delivery, backpack to Pune
(16, 'KV-20250206-0016', 9, 14, 'out_for_delivery',
     1799.00, 0.00, 0.00, 324.00, 2123.00,
     NULL, 'debit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-02-06 10:00:00', '2025-02-06 10:01:00', '2025-02-07 09:00:00', NULL,
     NULL),

-- Order 20: Vikram — out for delivery, charger to Chennai
(20, 'KV-20250209-0020', 2, 3, 'out_for_delivery',
     1899.00, 0.00, 0.00, 342.00, 2241.00,
     NULL, 'upi', 'paid', FALSE,
     NULL, NULL,
     '2025-02-09 10:00:00', '2025-02-09 10:01:00', '2025-02-09 16:00:00', NULL,
     NULL),

-- =============================================
-- RETURN REQUESTED (1)
-- =============================================

-- Order 22: Rahul — delivered Feb 5, return requested Feb 8 (within 7-day window)
-- Shoes too tight (size_issue)
(22, 'KV-20250203-0022', 6, 10, 'return_requested',
     2799.00, 0.00, 0.00, 504.00, 3303.00,
     NULL, 'credit_card', 'paid', FALSE,
     NULL, NULL,
     '2025-02-03 09:00:00', '2025-02-03 09:01:00', '2025-02-04 08:00:00', '2025-02-06 14:00:00',
     NULL),

-- =============================================
-- RETURNED (completed) (1)
-- =============================================

-- Order 23: Arun — mixer grinder died in 2 days, returned and refunded
(23, 'KV-20250105-0023', 3, 5, 'returned',
     3999.00, 0.00, 0.00, 720.00, 4719.00,
     NULL, 'upi', 'refunded', FALSE,
     NULL, NULL,
     '2025-01-05 12:00:00', '2025-01-05 12:01:00', '2025-01-06 10:00:00', '2025-01-09 09:00:00',
     NULL),

-- =============================================
-- FAILED DELIVERY (1)
-- =============================================

-- Order 24: Rahul — dumbbells, delivery failed (no one home at alt address)
(24, 'KV-20250202-0024', 6, 11, 'failed',
     1699.00, 49.00, 0.00, 315.00, 2063.00,
     NULL, 'upi', 'paid', FALSE,
     NULL, NULL,
     '2025-02-02 09:00:00', '2025-02-02 09:01:00', '2025-02-03 08:00:00', NULL,
     NULL),

-- =============================================
-- PENDING (just placed, not confirmed) (1)
-- =============================================

-- Order 25: Rohan — just placed COD order, pending confirmation
(25, 'KV-20250210-0025', 10, 15, 'pending',
     1499.00, 49.00, 0.00, 279.00, 1827.00,
     NULL, 'cod', 'pending', TRUE,
     NULL, NULL,
     '2025-02-10 22:00:00', NULL, NULL, NULL,
     NULL);


-- ============================================================
-- ORDER ITEMS
-- ============================================================
-- Maps each order to its product(s)
-- Multi-item orders: 6, 10, 18
-- Rest are single-item
-- ============================================================

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, total_price, item_status) VALUES

-- Order 1: Arjun → KVTech Nova 12 Pro (phone)
(1,  1,  1,  1, 21999.00, 21999.00, 'active'),

-- Order 2: Arjun → AirBuds Pro + Daily Sneaker
(2,  2,  7,  1,  3499.00,  3499.00, 'active'),
(3,  2,  13, 1,   999.00,   999.00, 'active'),

-- Order 3: Vikram → PowerGear UltraBook 14
(4,  3,  4,  1, 64999.00, 64999.00, 'active'),

-- Order 4: Vikram → Yoga Mat
(5,  4,  34, 1,   999.00,   999.00, 'active'),

-- Order 5: Sneha → Oxford Shirt
(6,  5,  18, 1,  1599.00,  1599.00, 'active'),

-- Order 6: Arun → multi-item: Oxford Shirt + Chinos + Dry-Fit Tee
(7,  6,  18, 1,  1599.00,  1599.00, 'active'),
(8,  6,  19, 1,  1999.00,  1999.00, 'active'),
(9,  6,  20, 1,   699.00,   699.00, 'active'),

-- Order 7: Ananya → Denim Jacket
(10, 7,  22, 1,  2499.00,  2499.00, 'active'),

-- Order 8: Priya → AirBuds Pro (shipped, in transit)
(11, 8,  7,  1,  3499.00,  3499.00, 'active'),

-- Order 9: Rohan → Analog Watch (delivered, within return window)
(12, 9,  24, 1,  2999.00,  2999.00, 'active'),

-- Order 10: Fatima → Floral Kurti + Sunglasses
(13, 10, 21, 1,  1099.00,  1099.00, 'active'),
(14, 10, 26, 1,  1499.00,  1499.00, 'active'),

-- Order 11: Siddharth → Resistance Bands (delivered, within return window)
(15, 11, 35, 1,   749.00,   749.00, 'active'),

-- Order 12: Rahul → OverEar 500 (cancelled)
(16, 12, 8,  1,  7499.00,  7499.00, 'cancelled'),

-- Order 13: Deepa → Mastering Python (first order, confirmed)
(17, 13, 31, 1,   599.00,   599.00, 'active'),

-- Order 14: Sneha → Air Fryer (processing, cancellable)
(18, 14, 27, 1,  5499.00,  5499.00, 'active'),

-- Order 15: Ananya → Maxi Dress (shipped, can't cancel — CP7)
(19, 15, 23, 1,  1899.00,  1899.00, 'active'),

-- Order 16: Meera → Laptop Backpack (out for delivery)
(20, 16, 25, 1,  1799.00,  1799.00, 'active'),

-- Order 17: Priya → Floral Kurti (confirmed, COD, cancellable)
(21, 17, 21, 1,  1099.00,  1099.00, 'active'),

-- Order 18: Arjun → Resistance Bands + Yoga Mat (processing, cancellable)
(22, 18, 35, 1,   749.00,   749.00, 'active'),
(23, 18, 34, 1,   999.00,   999.00, 'active'),

-- Order 19: Nisha → Runner X (shipped, en route to Mumbai)
(24, 19, 11, 1,  2799.00,  2799.00, 'active'),

-- Order 20: Vikram → GaN Charger (out for delivery)
(25, 20, 10, 1,  1899.00,  1899.00, 'active'),

-- Order 21: Nisha → Electric Kettle (cancelled COD)
(26, 21, 28, 1,  1199.00,  1199.00, 'cancelled'),

-- Order 22: Rahul → Runner X (delivered, return requested — size issue)
(27, 22, 11, 1,  2799.00,  2799.00, 'active'),

-- Order 23: Arun → Mixer Grinder (returned, defective)
(28, 23, 29, 1,  3999.00,  3999.00, 'returned'),

-- Order 24: Rahul → Dumbbells (failed delivery)
(29, 24, 36, 1,  1699.00,  1699.00, 'active'),

-- Order 25: Rohan → Daily Sneaker (pending COD)
(30, 25, 13, 1,  1499.00,  1499.00, 'active');
