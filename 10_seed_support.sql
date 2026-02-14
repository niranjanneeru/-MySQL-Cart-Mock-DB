-- ============================================================
-- 10_seed_support.sql
-- Support Tickets
-- ============================================================
-- These represent cases where either:
--   - Diya couldn't help and escalated (source: diya_escalation)
--   - User created a ticket directly (source: user_created)
--   - System auto-generated a ticket (source: system)
--
-- 8 tickets across different categories and statuses
-- Linked to specific orders where applicable
--
-- STATUS SPREAD:
--   open:                2
--   in_progress:         2
--   waiting_on_customer: 1
--   resolved:            2
--   closed:              1
-- ============================================================

USE kvkart;

INSERT INTO support_tickets (ticket_id, ticket_number, user_id, order_id, category, subject, description, priority, status, assigned_agent, source, created_at, updated_at, resolved_at) VALUES

-- Ticket 1: Rahul — return pickup not scheduled
-- Linked to Return 1 (Order 22), Diya escalated because pickup was delayed
(1, 'TKT-20250208-0001', 6, 22,
 'return_refund',
 'Return approved but pickup not scheduled yet',
 'I requested a return for my Runner X shoes (Order KV-20250203-0022) on Feb 8. It was approved but no pickup has been scheduled. Diya said the pickup should happen within 2-3 business days but it has been 2 days with no update. Please schedule the pickup ASAP.',
 'high',
 'in_progress',
 'Agent_Ravi',
 'diya_escalation',
 '2025-02-10 10:00:00', '2025-02-10 14:00:00', NULL),

-- Ticket 2: Rahul — failed delivery dispute
-- Linked to Order 24 (dumbbells), user claims he was home
(2, 'TKT-20250205-0002', 6, 24,
 'delivery_issue',
 'Delivery marked as failed but I was at home',
 'My order KV-20250202-0024 for dumbbells was marked as "delivery failed - no one available" on Feb 5. I was at home the entire day. The delivery person did not ring the bell or call me. I need this re-delivered immediately. This is the second time this has happened at my Kakkanad address.',
 'high',
 'open',
 NULL,
 'diya_escalation',
 '2025-02-05 17:00:00', '2025-02-05 17:00:00', NULL),

-- Ticket 3: Arun — defective mixer complaint (resolved)
-- Linked to Order 23, return completed, refund done
(3, 'TKT-20250110-0003', 3, 23,
 'product_complaint',
 'Defective mixer grinder — motor died in 2 days',
 'The HomeChef Mixer Grinder 750W I received on Jan 9 stopped working after just 2 days. The motor makes a loud grinding noise and shuts off. This is clearly a manufacturing defect. I have already raised a return request. Please ensure the refund is processed quickly.',
 'urgent',
 'resolved',
 'Agent_Preethi',
 'user_created',
 '2025-01-10 10:00:00', '2025-01-22 09:00:00', '2025-01-22 09:00:00'),

-- Ticket 4: Vikram — warranty inquiry for watch (resolved)
-- Linked to Order 4 (yoga mat? No — this is about a watch he hasn't ordered yet)
-- Actually, Vikram doesn't have a watch order. Let me link to NULL.
-- He's asking a general product question.
(4, 'TKT-20250204-0004', 2, NULL,
 'general_inquiry',
 'Warranty information for TrendSetters Analog Watch',
 'I am considering buying the TrendSetters Analog Watch. Does it come with a manufacturer warranty? If so, how long is it and what does it cover? Diya said she could not find warranty information in the system.',
 'low',
 'resolved',
 'Agent_Ravi',
 'diya_escalation',
 '2025-02-04 09:00:00', '2025-02-04 15:00:00', '2025-02-04 15:00:00'),

-- Ticket 5: Ananya — can't cancel shipped order
-- Linked to Order 15 (maxi dress, shipped) — CP7 scenario
-- Diya correctly refused to cancel, user wants human support
(5, 'TKT-20250210-0005', 8, 15,
 'order_issue',
 'Want to cancel order but Diya says it is already shipped',
 'I placed order KV-20250205-0015 for a Maxi Dress but I changed my mind. I asked Diya to cancel it but she said the order is already shipped and cannot be cancelled. Can a support agent cancel it? I do not want this item anymore. Please help.',
 'medium',
 'in_progress',
 'Agent_Meghna',
 'diya_escalation',
 '2025-02-10 09:00:00', '2025-02-10 11:00:00', NULL),

-- Ticket 6: Sneha — payment deducted but order shows processing
-- Linked to Order 14 (air fryer, wallet payment)
-- User is worried because wallet was debited but order hasn't shipped
(6, 'TKT-20250210-0006', 7, 14,
 'payment_issue',
 'Wallet balance deducted but order still in processing',
 'I placed order KV-20250209-0014 for an Air Fryer yesterday and paid ₹5,309 from my KV Wallet. The amount was deducted immediately but the order is still showing "processing" after 24 hours. When will it ship? Is my money safe? Please confirm.',
 'medium',
 'waiting_on_customer',
 'Agent_Preethi',
 'user_created',
 '2025-02-10 12:00:00', '2025-02-10 15:00:00', NULL),
 -- waiting_on_customer: agent replied saying it will ship within 24hrs and asked if user wants to wait or cancel

-- Ticket 7: Fatima — return rejected, user disagrees
-- Linked to Return 3 (Order 10, rejected because outside window)
(7, 'TKT-20250209-0007', 11, 10,
 'return_refund',
 'Return rejected unfairly — I want to escalate',
 'My return request for the Floral Kurti from order KV-20250125-0010 was rejected. The system says I am outside the 7-day return window but I believe the color difference qualifies as "not as described" and should have a longer window. The product photos on the website are misleading. I want this escalated to a senior agent.',
 'medium',
 'open',
 NULL,
 'diya_escalation',
 '2025-02-09 15:00:00', '2025-02-09 15:00:00', NULL),

-- Ticket 8: Karthik — suspended account inquiry
-- User 14 is suspended, wants to know why and how to reinstate
(8, 'TKT-20250115-0008', 14, NULL,
 'account_issue',
 'Account suspended without clear explanation',
 'My account has been suspended and I cannot place any orders. I was a regular customer and I do not understand why this happened. I may have returned a few items but they were all genuinely defective or wrong. Please review my account and reinstate it. I have been a customer since March 2024.',
 'high',
 'closed',
 'Agent_Ravi',
 'user_created',
 '2025-01-15 10:00:00', '2025-01-20 16:00:00', '2025-01-20 16:00:00');
 -- closed: agent reviewed, found >50% return rate, suspension upheld, user informed
