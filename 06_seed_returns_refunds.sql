-- ============================================================
-- 06_seed_returns_refunds.sql
-- Return Requests + Refunds
-- ============================================================
-- Covers CP3 (refund timelines) and CP7 (eligibility checks)
--
-- RETURN REQUESTS (3):
--   Return 1: Order 22, Rahul — approved, pickup scheduled (within 7-day window)
--   Return 2: Order 23, Arun  — refund_completed (defective mixer)
--   Return 3: Order 10, Fatima — REJECTED (outside 7-day window)
--
-- REFUNDS (3):
--   Refund 1: Order 12 cancellation — Rahul, completed (UPI, fast)
--   Refund 2: Order 23 return      — Arun, completed (UPI refund)
--   Refund 3: Order 22 return      — Rahul, initiated but pending (credit card, slower)
--
-- NOTE: Order 21 (Nisha's cancelled COD) has no refund — no payment was collected.
-- ============================================================

USE kvkart;

-- ============================================================
-- RETURN REQUESTS
-- ============================================================

INSERT INTO return_requests (return_id, order_id, order_item_id, user_id, reason, reason_detail, return_status, pickup_date, rejection_reason, requested_at, resolved_at) VALUES

-- Return 1: Rahul's Runner X (Order 22)
-- Delivered Feb 6, requested Feb 8 → 2 days = within 7-day window ✓
-- Status: approved, pickup scheduled for Feb 12
(1, 22, 27, 6,
 'size_issue',
 'Shoes are too tight. I normally wear size 9 but these feel like size 8. Need one size up or a full refund.',
 'approved',
 '2025-02-12',    -- pickup_date
 NULL,             -- no rejection
 '2025-02-08 10:00:00',  -- requested_at
 NULL),                    -- not yet resolved

-- Return 2: Arun's Mixer Grinder (Order 23)
-- Delivered Jan 9, requested Jan 10 → 1 day = within 7-day window ✓
-- Electronics have 10-day window per policy, so doubly within window
-- Status: refund_completed (full cycle done)
(2, 23, 28, 3,
 'defective',
 'Motor stopped working completely after just 2 days of normal use. Makes a grinding noise and then shuts off. Clearly a manufacturing defect.',
 'refund_completed',
 '2025-01-12',    -- pickup_date
 NULL,             -- no rejection
 '2025-01-10 09:00:00',  -- requested_at
 '2025-01-22 14:00:00'), -- resolved_at (refund completed)

-- Return 3: Fatima's Kurti (Order 10, item 13 = Floral Kurti)
-- Delivered Jan 31, requested Feb 9 → 9 days = OUTSIDE 7-day window ✗
-- Status: rejected
(3, 10, 13, 11,
 'changed_mind',
 'The color looks different from the photos. I want to return this.',
 'rejected',
 NULL,             -- no pickup scheduled (rejected)
 'Return request denied: The 7-day return window for this item expired on 2025-02-07. Your request was submitted on 2025-02-09, which is 2 days past the eligible window. As per KV Kart return policy, returns cannot be processed after the window closes.',
 '2025-02-09 11:00:00',  -- requested_at
 '2025-02-09 14:00:00'); -- resolved_at (rejected same day)


-- ============================================================
-- REFUNDS
-- ============================================================

INSERT INTO refunds (refund_id, order_id, return_id, user_id, refund_type, refund_amount, refund_method, refund_status, expected_completion_date, actual_completion_date, transaction_reference, initiated_at, completed_at) VALUES

-- Refund 1: Rahul's cancelled order (Order 12)
-- Cancelled before shipping, paid via UPI
-- UPI refund: 2-4 business days per policy
-- Initiated Feb 1, completed Feb 3 (2 business days) ✓
(1, 12, NULL, 6,
 'cancellation',
 8849.00,
 'original_payment',
 'completed',
 '2025-02-05',         -- expected (4 biz days from initiation)
 '2025-02-03',         -- actual (came early — 2 days)
 'REF-UPI-20250203-001',
 '2025-02-01 16:30:00',  -- initiated_at
 '2025-02-03 10:00:00'), -- completed_at

-- Refund 2: Arun's returned mixer (Order 23)
-- Paid via UPI, returned item inspected and approved
-- UPI refund: 2-4 business days per policy
-- Initiated Jan 18 (after inspection), completed Jan 20
(2, 23, 2, 3,
 'return',
 4719.00,
 'original_payment',
 'completed',
 '2025-01-22',         -- expected
 '2025-01-20',         -- actual (within timeline)
 'REF-UPI-20250120-002',
 '2025-01-18 10:00:00',  -- initiated_at
 '2025-01-20 09:00:00'), -- completed_at

-- Refund 3: Rahul's Runner X return (Order 22)
-- Paid via credit card, return approved but pickup not yet done
-- Credit card refund: 5-7 business days per policy
-- Initiated Feb 9 (after approval), not yet completed
-- This is the "where's my refund?" scenario teams will encounter
(3, 22, 1, 6,
 'return',
 3303.00,
 'original_payment',
 'initiated',
 '2025-02-18',         -- expected (7 biz days from Feb 9)
 NULL,                  -- not completed yet
 NULL,                  -- no transaction ref yet
 '2025-02-09 11:00:00',  -- initiated_at
 NULL);                    -- not completed
