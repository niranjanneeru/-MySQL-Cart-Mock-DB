-- ============================================================
-- 07_seed_payments.sql
-- Payments + Wallets + Wallet Transactions
-- ============================================================
-- 25 payments (1 per order), all consistent with order payment_method
-- 15 wallets (1 per user)
-- Wallet transactions for topups, purchases, cashback, refunds
-- ============================================================

USE kvkart;

-- ============================================================
-- PAYMENTS (25)
-- ============================================================
-- payment_status mapping:
--   order.payment_status = 'paid'     → payment.payment_status = 'success'
--   order.payment_status = 'refunded' → payment.payment_status = 'refunded'
--   order.payment_status = 'pending'  → payment.payment_status = 'initiated'
-- ============================================================

INSERT INTO payments (payment_id, order_id, user_id, payment_method, payment_gateway, transaction_id, amount, currency, payment_status, paid_at, created_at) VALUES

-- Order 1: Arjun, UPI, ₹25,959
(1,  1,  1,  'upi',         'razorpay', 'TXN-RP-20250115-001', 25959.00, 'INR', 'success',   '2025-01-15 10:31:00', '2025-01-15 10:30:00'),

-- Order 2: Arjun, Credit Card, ₹4,718
(2,  2,  1,  'credit_card', 'razorpay', 'TXN-RP-20250125-002',  4718.00, 'INR', 'success',   '2025-01-25 18:01:00', '2025-01-25 18:00:00'),

-- Order 3: Vikram, Net Banking, ₹76,699
(3,  3,  2,  'net_banking', 'razorpay', 'TXN-RP-20250110-003', 76699.00, 'INR', 'success',   '2025-01-10 08:01:00', '2025-01-10 08:00:00'),

-- Order 4: Vikram, UPI, ₹1,237
(4,  4,  2,  'upi',         'phonepe',  'TXN-PP-20250120-004',  1237.00, 'INR', 'success',   '2025-01-20 10:01:00', '2025-01-20 10:00:00'),

-- Order 5: Sneha, UPI, ₹1,945
(5,  5,  7,  'upi',         'razorpay', 'TXN-RP-20250130-005',  1945.00, 'INR', 'success',   '2025-01-30 15:01:00', '2025-01-30 15:00:00'),

-- Order 6: Arun, Credit Card, ₹5,071
(6,  6,  3,  'credit_card', 'razorpay', 'TXN-RP-20250118-006',  5071.00, 'INR', 'success',   '2025-01-18 09:01:00', '2025-01-18 09:00:00'),

-- Order 7: Ananya, Credit Card, ₹2,949
(7,  7,  8,  'credit_card', 'razorpay', 'TXN-RP-20250128-007',  2949.00, 'INR', 'success',   '2025-01-28 14:01:00', '2025-01-28 14:00:00'),

-- Order 8: Priya, Debit Card, ₹4,187
(8,  8,  5,  'debit_card',  'razorpay', 'TXN-RP-20250207-008',  4187.00, 'INR', 'success',   '2025-02-07 12:01:00', '2025-02-07 12:00:00'),

-- Order 9: Rohan, Debit Card, ₹3,539
(9,  9,  10, 'debit_card',  'razorpay', 'TXN-RP-20250201-009',  3539.00, 'INR', 'success',   '2025-02-01 11:01:00', '2025-02-01 11:00:00'),

-- Order 10: Fatima, UPI, ₹3,066
(10, 10, 11, 'upi',         'razorpay', 'TXN-RP-20250125-010',  3066.00, 'INR', 'success',   '2025-01-25 12:01:00', '2025-01-25 12:00:00'),

-- Order 11: Siddharth, COD, ₹942 (paid on delivery)
(11, 11, 12, 'cod',         NULL,       'TXN-COD-20250205-011',   942.00, 'INR', 'success',   '2025-02-05 11:00:00', '2025-02-01 14:00:00'),

-- Order 12: Rahul, UPI, ₹8,849 (cancelled → refunded)
(12, 12, 6,  'upi',         'razorpay', 'TXN-RP-20250201-012',  8849.00, 'INR', 'refunded',  '2025-02-01 11:01:00', '2025-02-01 11:00:00'),

-- Order 13: Deepa, UPI, ₹647
(13, 13, 13, 'upi',         'razorpay', 'TXN-RP-20250210-013',   647.00, 'INR', 'success',   '2025-02-10 15:01:00', '2025-02-10 15:00:00'),

-- Order 14: Sneha, Wallet, ₹5,309
(14, 14, 7,  'wallet',      NULL,       'TXN-WLT-20250209-014',  5309.00, 'INR', 'success',   '2025-02-09 11:01:00', '2025-02-09 11:00:00'),

-- Order 15: Ananya, UPI, ₹2,299
(15, 15, 8,  'upi',         'phonepe',  'TXN-PP-20250205-015',   2299.00, 'INR', 'success',   '2025-02-05 16:01:00', '2025-02-05 16:00:00'),

-- Order 16: Meera, Debit Card, ₹2,123
(16, 16, 9,  'debit_card',  'razorpay', 'TXN-RP-20250206-016',  2123.00, 'INR', 'success',   '2025-02-06 10:01:00', '2025-02-06 10:00:00'),

-- Order 17: Priya, COD, ₹1,355 (confirmed, not yet paid)
(17, 17, 5,  'cod',         NULL,       NULL,                     1355.00, 'INR', 'initiated', NULL,                  '2025-02-10 20:00:00'),

-- Order 18: Arjun, Wallet, ₹2,063
(18, 18, 1,  'wallet',      NULL,       'TXN-WLT-20250210-018',  2063.00, 'INR', 'success',   '2025-02-10 08:01:00', '2025-02-10 08:00:00'),

-- Order 19: Nisha, Credit Card, ₹3,303
(19, 19, 4,  'credit_card', 'razorpay', 'TXN-RP-20250208-019',  3303.00, 'INR', 'success',   '2025-02-08 09:01:00', '2025-02-08 09:00:00'),

-- Order 20: Vikram, UPI, ₹2,241
(20, 20, 2,  'upi',         'paytm',    'TXN-PT-20250209-020',  2241.00, 'INR', 'success',   '2025-02-09 10:01:00', '2025-02-09 10:00:00'),

-- Order 21: Nisha, COD, ₹1,473 (cancelled, never paid)
(21, 21, 4,  'cod',         NULL,       NULL,                     1473.00, 'INR', 'initiated', NULL,                  '2025-02-05 10:00:00'),

-- Order 22: Rahul, Credit Card, ₹3,303
(22, 22, 6,  'credit_card', 'razorpay', 'TXN-RP-20250203-022',  3303.00, 'INR', 'success',   '2025-02-03 09:01:00', '2025-02-03 09:00:00'),

-- Order 23: Arun, UPI, ₹4,719 (returned → refunded)
(23, 23, 3,  'upi',         'razorpay', 'TXN-RP-20250105-023',  4719.00, 'INR', 'refunded',  '2025-01-05 12:01:00', '2025-01-05 12:00:00'),

-- Order 24: Rahul, UPI, ₹2,063
(24, 24, 6,  'upi',         'razorpay', 'TXN-RP-20250202-024',  2063.00, 'INR', 'success',   '2025-02-02 09:01:00', '2025-02-02 09:00:00'),

-- Order 25: Rohan, COD, ₹1,827 (just placed, pending)
(25, 25, 10, 'cod',         NULL,       NULL,                     1827.00, 'INR', 'initiated', NULL,                  '2025-02-10 22:00:00');


-- ============================================================
-- WALLETS (15 — one per user)
-- ============================================================
-- Some users have balance from topups, cashback, or refunds
-- Some are zero
-- ============================================================

INSERT INTO wallet (wallet_id, user_id, balance, last_updated_at) VALUES
(1,  1,   1187.00, '2025-02-10 08:01:00'),  -- Arjun: topped up 5000, spent 2063 (Order 18) + 1750 earlier
(2,  2,    350.00, '2025-02-01 10:00:00'),  -- Vikram: cashback credit
(3,  3,   4719.00, '2025-01-20 09:00:00'),  -- Arun: refund from Order 23 went to wallet
(4,  4,   2500.00, '2025-02-01 09:00:00'),  -- Nisha: topped up, premium user
(5,  5,      0.00, '2025-02-07 12:00:00'),  -- Priya: zero
(6,  6,    500.00, '2025-02-03 10:00:00'),  -- Rahul: cashback
(7,  7,    691.00, '2025-02-09 11:01:00'),  -- Sneha: had 6000, spent 5309 (Order 14)
(8,  8,      0.00, '2025-01-28 14:00:00'),  -- Ananya: zero
(9,  9,      0.00, '2025-02-06 10:00:00'),  -- Meera: zero
(10, 10,    200.00, '2025-01-15 09:00:00'),  -- Rohan: small cashback
(11, 11,      0.00, '2025-01-25 12:00:00'),  -- Fatima: zero
(12, 12,      0.00, '2025-02-01 14:00:00'),  -- Siddharth: zero
(13, 13,    100.00, '2025-02-01 10:00:00'),  -- Deepa: welcome bonus
(14, 14,      0.00, '2024-03-10 11:00:00'),  -- Karthik: suspended, zero
(15, 15,    150.00, '2024-11-30 16:00:00');  -- Tanya: deactivated, small remaining balance


-- ============================================================
-- WALLET TRANSACTIONS
-- ============================================================
-- Realistic history for users with wallet activity
-- ============================================================

INSERT INTO wallet_transactions (txn_id, wallet_id, txn_type, amount, description, reference_type, reference_id, created_at) VALUES

-- === Arjun (wallet 1) ===
-- Topped up 5000, spent 1750 on earlier small purchases, spent 2063 on Order 18
(1,  1, 'credit', 5000.00, 'Wallet top-up via UPI',                       'topup',       NULL,  '2025-01-20 10:00:00'),
(2,  1, 'debit',  1750.00, 'Purchase: misc items (before workshop data)',  'purchase',    NULL,  '2025-02-01 14:00:00'),
(3,  1, 'debit',  2063.00, 'Purchase: Order KV-20250210-0018',            'purchase',    '18',  '2025-02-10 08:01:00'),

-- === Vikram (wallet 2) ===
-- Cashback on laptop order
(4,  2, 'credit',  350.00, 'Cashback: 0.5% on Order KV-20250110-0003',   'cashback',    '3',   '2025-01-14 16:00:00'),

-- === Arun (wallet 3) ===
-- Refund from returned mixer went to wallet
(5,  3, 'credit', 4719.00, 'Refund: Order KV-20250105-0023 (returned)',   'refund',      '23',  '2025-01-20 09:00:00'),

-- === Nisha (wallet 4) ===
-- Topped up wallet
(6,  4, 'credit', 2500.00, 'Wallet top-up via UPI',                       'topup',       NULL,  '2025-02-01 09:00:00'),

-- === Rahul (wallet 6) ===
-- Cashback
(7,  6, 'credit',  500.00, 'Cashback: Festive season bonus',              'cashback',    NULL,  '2025-02-03 10:00:00'),

-- === Sneha (wallet 7) ===
-- Topped up 6000, spent 5309 on air fryer (Order 14)
(8,  7, 'credit', 6000.00, 'Wallet top-up via UPI',                       'topup',       NULL,  '2025-02-08 10:00:00'),
(9,  7, 'debit',  5309.00, 'Purchase: Order KV-20250209-0014',            'purchase',    '14',  '2025-02-09 11:01:00'),

-- === Rohan (wallet 10) ===
-- Small cashback
(10, 10, 'credit',  200.00, 'Cashback: New Year promo',                   'cashback',    NULL,  '2025-01-15 09:00:00'),

-- === Deepa (wallet 13) ===
-- Welcome bonus for new signup
(11, 13, 'credit',  100.00, 'Welcome bonus: New account signup reward',   'promotional', NULL,  '2025-02-01 10:00:00');
