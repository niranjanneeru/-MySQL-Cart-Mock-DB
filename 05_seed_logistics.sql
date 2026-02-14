-- ============================================================
-- 05_seed_logistics.sql
-- Logistics Partners + Shipments + Tracking Events + Delivery Estimates
-- ============================================================
-- This is KVFast — the logistics backbone Diya queries (CP6).
-- Diya must use delivery_estimates for "when will it reach?" — not guess.
-- Shipment tracking is the source of truth for "where is my order?"
-- ============================================================

USE kvkart;

-- ============================================================
-- LOGISTICS PARTNERS (4)
-- ============================================================

INSERT INTO logistics_partners (partner_id, name, tracking_url_template, avg_delivery_days, is_active) VALUES
(1, 'KVFast Express',    'https://track.kvfast.in/awb/{awb}',        3, TRUE),
(2, 'KVFast Standard',   'https://track.kvfast.in/awb/{awb}',        6, TRUE),
(3, 'BlueDart',          'https://www.bluedart.com/tracking/{awb}',   5, TRUE),
(4, 'Delhivery',         'https://www.delhivery.com/track/{awb}',     5, TRUE);


-- ============================================================
-- SHIPMENTS (17)
-- ============================================================
-- One shipment per shipped/delivered/failed order
-- No shipments for: pending (25), confirmed (13,17), processing (14,18), cancelled (12,21)
--
-- Partner assignment logic:
--   KVFast Express (1): local/nearby cities, premium users, high-value
--   KVFast Standard (2): farther cities, standard delivery
--   BlueDart (3): some inter-state
--   Delhivery (4): some inter-state
-- ============================================================

INSERT INTO shipments (shipment_id, order_id, logistics_partner_id, awb_number, shipment_status, origin_city, destination_city, destination_pincode, estimated_delivery_date, actual_delivery_date, weight_grams, last_location, last_updated_at, created_at) VALUES

-- === DELIVERED (10) ===

-- Shipment 1: Order 1 — Arjun's phone, Kochi→Kochi, Express
(1,  1,  1, 'KVF10001001', 'delivered',
     'Kochi', 'Kochi', '682036',
     '2025-01-18', '2025-01-18', 220,
     'Panampilly Nagar, Kochi - Delivered',
     '2025-01-18 11:00:00', '2025-01-15 14:00:00'),

-- Shipment 2: Order 2 — Arjun's earbuds+sneaker, Kochi→Kochi (work), Express
(2,  2,  1, 'KVF10001002', 'delivered',
     'Kochi', 'Kochi', '682042',
     '2025-01-28', '2025-01-28', 370,
     'Infopark Phase 2, Kochi - Delivered',
     '2025-01-28 16:00:00', '2025-01-25 20:00:00'),

-- Shipment 3: Order 3 — Vikram's laptop, Kochi→Chennai, Express (premium+high value)
(3,  3,  1, 'KVF10001003', 'delivered',
     'Kochi', 'Chennai', '600017',
     '2025-01-14', '2025-01-14', 1450,
     'T Nagar, Chennai - Delivered',
     '2025-01-14 15:00:00', '2025-01-10 12:00:00'),

-- Shipment 4: Order 4 — Vikram's yoga mat, Kochi→Chennai, Standard (low value)
(4,  4,  2, 'KVF20001004', 'delivered',
     'Kochi', 'Chennai', '600017',
     '2025-01-25', '2025-01-23', 1230,
     'T Nagar, Chennai - Delivered',
     '2025-01-23 14:00:00', '2025-01-20 12:00:00'),

-- Shipment 5: Order 5 — Sneha's shirt, Kochi→Ahmedabad, Standard
(5,  5,  2, 'KVF20001005', 'delivered',
     'Kochi', 'Ahmedabad', '380015',
     '2025-02-05', '2025-02-04', 210,
     'SG Highway, Ahmedabad - Delivered',
     '2025-02-04 12:00:00', '2025-01-30 18:00:00'),

-- Shipment 6: Order 6 — Arun's 3-item clothing, Kochi→Delhi, Standard
(6,  6,  2, 'KVF20001006', 'delivered',
     'Kochi', 'New Delhi', '110001',
     '2025-01-25', '2025-01-24', 620,
     'Connaught Place, New Delhi - Delivered',
     '2025-01-24 11:00:00', '2025-01-18 14:00:00'),

-- Shipment 7: Order 7 — Ananya's denim jacket, Kochi→Hyderabad, BlueDart
(7,  7,  3, 'BD30001007', 'delivered',
     'Kochi', 'Hyderabad', '500033',
     '2025-02-02', '2025-02-01', 480,
     'Jubilee Hills, Hyderabad - Delivered',
     '2025-02-01 10:00:00', '2025-01-28 18:00:00'),

-- Shipment 8: Order 9 — Rohan's watch, Bangalore→Bangalore, Express (local)
(8,  9,  1, 'KVF10001008', 'delivered',
     'Bangalore', 'Bangalore', '560034',
     '2025-02-04', '2025-02-05', 120,
     'Koramangala, Bangalore - Delivered',
     '2025-02-05 16:00:00', '2025-02-01 14:00:00'),

-- Shipment 9: Order 10 — Fatima's kurti+sunglasses, Kochi→Jaipur, Delhivery
(9,  10, 4, 'DEL40001009', 'delivered',
     'Kochi', 'Jaipur', '302001',
     '2025-02-01', '2025-01-31', 260,
     'MI Road, Jaipur - Delivered',
     '2025-01-31 14:00:00', '2025-01-25 16:00:00'),

-- Shipment 10: Order 11 — Siddharth's bands, Kochi→Kochi, Express (local)
(10, 11, 1, 'KVF10001010', 'delivered',
     'Kochi', 'Kochi', '682031',
     '2025-02-04', '2025-02-05', 330,
     'Marine Drive, Kochi - Delivered',
     '2025-02-05 11:00:00', '2025-02-01 16:00:00'),

-- === SHIPPED / IN TRANSIT (3) ===

-- Shipment 11: Order 8 — Priya's AirBuds, Kochi→Bangalore, Express
(11, 8,  1, 'KVF10001011', 'in_transit',
     'Kochi', 'Bangalore', '560025',
     '2025-02-11', NULL, 85,
     'Bangalore Sort Facility',
     '2025-02-10 22:00:00', '2025-02-07 14:00:00'),

-- Shipment 12: Order 15 — Ananya's maxi dress, Kochi→Hyderabad, BlueDart
-- (This is the CP7 trap — she wants to cancel but it's shipped)
(12, 15, 3, 'BD30001012', 'in_transit',
     'Kochi', 'Hyderabad', '500033',
     '2025-02-10', NULL, 280,
     'Hyderabad Sort Center',
     '2025-02-09 18:00:00', '2025-02-05 20:00:00'),

-- Shipment 13: Order 19 — Nisha's shoes, Kochi→Mumbai, Delhivery
(13, 19, 4, 'DEL40001013', 'in_transit',
     'Kochi', 'Mumbai', '400050',
     '2025-02-12', NULL, 350,
     'Pune Transit Hub',
     '2025-02-10 06:00:00', '2025-02-08 12:00:00'),

-- === OUT FOR DELIVERY (2) ===

-- Shipment 14: Order 16 — Meera's backpack, Kochi→Pune, Delhivery
(14, 16, 4, 'DEL40001014', 'out_for_delivery',
     'Kochi', 'Pune', '411004',
     '2025-02-10', NULL, 780,
     'FC Road Area, Pune - Out for Delivery',
     '2025-02-10 07:00:00', '2025-02-06 14:00:00'),

-- Shipment 15: Order 20 — Vikram's charger, Kochi→Chennai, Express
(15, 20, 1, 'KVF10001015', 'out_for_delivery',
     'Kochi', 'Chennai', '600017',
     '2025-02-10', NULL, 150,
     'T Nagar, Chennai - Out for Delivery',
     '2025-02-10 08:30:00', '2025-02-09 12:00:00'),

-- === RETURN-RELATED (2) ===

-- Shipment 16: Order 22 — Rahul's Runner X, delivered then return requested
(16, 22, 1, 'KVF10001016', 'delivered',
     'Kochi', 'Kochi', '682016',
     '2025-02-06', '2025-02-06', 350,
     'Warrior Road, Ernakulam - Delivered',
     '2025-02-06 14:00:00', '2025-02-03 12:00:00'),

-- Shipment 17: Order 23 — Arun's mixer, delivered then returned to origin
(17, 23, 2, 'KVF20001017', 'returned_to_origin',
     'Kochi', 'New Delhi', '110001',
     '2025-01-10', '2025-01-09', 3530,
     'Returned to Kochi Warehouse',
     '2025-01-20 09:00:00', '2025-01-05 16:00:00'),

-- === FAILED DELIVERY (1) ===

-- Shipment 18: Order 24 — Rahul's dumbbells, failed at alt address
(18, 24, 1, 'KVF10001018', 'failed_attempt',
     'Kochi', 'Kochi', '682030',
     '2025-02-05', NULL, 10050,
     'Kakkanad - Delivery Failed (No one available)',
     '2025-02-05 16:00:00', '2025-02-02 14:00:00');


-- ============================================================
-- SHIPMENT TRACKING EVENTS
-- ============================================================
-- Detailed events for key scenario shipments:
--   Shipment 11 (Order 8):  Priya's in-transit — full journey so far
--   Shipment 12 (Order 15): Ananya's shipped — CP7 cancel trap
--   Shipment 15 (Order 20): Vikram's out-for-delivery — near completion
--   Shipment 18 (Order 24): Rahul's failed — shows failure reason
--   Shipment 3  (Order 3):  Vikram's delivered laptop — complete journey
-- Minimal events for remaining shipments (just key milestones)
-- ============================================================

INSERT INTO shipment_tracking_events (event_id, shipment_id, event_status, location, description, event_timestamp) VALUES

-- === Shipment 3 (Order 3): Vikram's laptop — FULL DELIVERED JOURNEY ===
(1,  3, 'label_created',    'Kochi',                  'Shipping label generated',                         '2025-01-10 12:00:00'),
(2,  3, 'picked_up',        'Kochi Warehouse',        'Package picked up from warehouse',                 '2025-01-11 09:00:00'),
(3,  3, 'in_transit',       'Kochi Sort Facility',    'Package processed and dispatched',                 '2025-01-11 18:00:00'),
(4,  3, 'in_transit',       'Coimbatore Hub',         'In transit via Coimbatore',                        '2025-01-12 06:00:00'),
(5,  3, 'at_hub',           'Chennai Hub',            'Arrived at Chennai distribution center',           '2025-01-13 04:00:00'),
(6,  3, 'out_for_delivery', 'T Nagar, Chennai',       'Package is out for delivery',                      '2025-01-14 09:00:00'),
(7,  3, 'delivered',        'T Nagar, Chennai',       'Delivered — Received by: Vikram Iyer',             '2025-01-14 15:00:00'),

-- === Shipment 11 (Order 8): Priya's AirBuds — IN TRANSIT ===
(8,  11, 'label_created',   'Kochi',                  'Shipping label generated',                         '2025-02-07 14:00:00'),
(9,  11, 'picked_up',       'Kochi Warehouse',        'Package picked up from warehouse',                 '2025-02-08 10:00:00'),
(10, 11, 'in_transit',      'Kochi Sort Facility',    'Package processed at sort facility',               '2025-02-08 18:00:00'),
(11, 11, 'in_transit',      'Coimbatore Hub',         'In transit through Coimbatore',                    '2025-02-09 06:00:00'),
(12, 11, 'in_transit',      'Salem Transit Point',    'Crossed Salem, moving toward Bangalore',           '2025-02-09 22:00:00'),
(13, 11, 'in_transit',      'Bangalore Sort Facility','Arrived at destination city sort center',           '2025-02-10 22:00:00'),

-- === Shipment 12 (Order 15): Ananya's Maxi Dress — SHIPPED (CP7 TRAP) ===
(14, 12, 'label_created',   'Kochi',                  'Shipping label generated',                         '2025-02-05 20:00:00'),
(15, 12, 'picked_up',       'Kochi Warehouse',        'Package picked up from warehouse',                 '2025-02-06 14:00:00'),
(16, 12, 'in_transit',      'Kochi Sort Facility',    'Dispatched from Kochi',                            '2025-02-06 22:00:00'),
(17, 12, 'in_transit',      'Bangalore Hub',          'In transit via Bangalore',                         '2025-02-08 10:00:00'),
(18, 12, 'in_transit',      'Hyderabad Sort Center',  'Arrived at Hyderabad sort center',                 '2025-02-09 18:00:00'),

-- === Shipment 15 (Order 20): Vikram's charger — OUT FOR DELIVERY ===
(19, 15, 'label_created',   'Kochi',                  'Shipping label generated',                         '2025-02-09 12:00:00'),
(20, 15, 'picked_up',       'Kochi Warehouse',        'Package picked up',                                '2025-02-09 16:00:00'),
(21, 15, 'in_transit',      'Kochi Sort Facility',    'Express dispatch — priority shipment',             '2025-02-09 20:00:00'),
(22, 15, 'at_hub',          'Chennai Hub',            'Arrived at Chennai hub (overnight express)',        '2025-02-10 05:00:00'),
(23, 15, 'out_for_delivery','T Nagar, Chennai',       'Package is out for delivery',                      '2025-02-10 08:30:00'),

-- === Shipment 18 (Order 24): Rahul's dumbbells — FAILED DELIVERY ===
(24, 18, 'label_created',   'Kochi',                  'Shipping label generated',                         '2025-02-02 14:00:00'),
(25, 18, 'picked_up',       'Kochi Warehouse',        'Package picked up (heavy — 10kg)',                 '2025-02-03 08:00:00'),
(26, 18, 'in_transit',      'Kochi Hub',              'In transit within Kochi',                          '2025-02-03 16:00:00'),
(27, 18, 'out_for_delivery','Kakkanad, Kochi',        'Out for delivery',                                 '2025-02-05 09:00:00'),
(28, 18, 'failed_attempt',  'Kakkanad, Kochi',        'Delivery failed — No one available at door. Will reattempt next business day.', '2025-02-05 16:00:00'),

-- === Shipment 13 (Order 19): Nisha's shoes — IN TRANSIT (Mumbai bound) ===
(29, 13, 'label_created',   'Kochi',                  'Shipping label generated',                         '2025-02-08 12:00:00'),
(30, 13, 'picked_up',       'Kochi Warehouse',        'Package picked up',                                '2025-02-09 08:00:00'),
(31, 13, 'in_transit',      'Kochi Sort Facility',    'Dispatched from Kochi',                            '2025-02-09 16:00:00'),
(32, 13, 'in_transit',      'Pune Transit Hub',       'In transit via Pune, en route to Mumbai',          '2025-02-10 06:00:00'),

-- === Shipment 14 (Order 16): Meera's backpack — OUT FOR DELIVERY ===
(33, 14, 'label_created',   'Kochi',                  'Shipping label generated',                         '2025-02-06 14:00:00'),
(34, 14, 'picked_up',       'Kochi Warehouse',        'Package picked up',                                '2025-02-07 09:00:00'),
(35, 14, 'in_transit',      'Kochi Sort Facility',    'Dispatched from Kochi',                            '2025-02-07 18:00:00'),
(36, 14, 'in_transit',      'Bangalore Hub',          'In transit via Bangalore',                         '2025-02-08 16:00:00'),
(37, 14, 'at_hub',          'Pune Hub',               'Arrived at Pune distribution center',              '2025-02-09 14:00:00'),
(38, 14, 'out_for_delivery','FC Road, Pune',          'Package is out for delivery',                      '2025-02-10 07:00:00'),

-- === Shipment 17 (Order 23): Arun's mixer — RETURNED TO ORIGIN ===
(39, 17, 'label_created',   'Kochi',                  'Shipping label generated',                         '2025-01-05 16:00:00'),
(40, 17, 'picked_up',       'Kochi Warehouse',        'Package picked up',                                '2025-01-06 10:00:00'),
(41, 17, 'in_transit',      'Kochi Sort Facility',    'Dispatched from Kochi',                            '2025-01-06 20:00:00'),
(42, 17, 'at_hub',          'Delhi Hub',              'Arrived at Delhi distribution center',             '2025-01-08 06:00:00'),
(43, 17, 'out_for_delivery','Connaught Place, Delhi', 'Out for delivery',                                 '2025-01-09 08:00:00'),
(44, 17, 'delivered',       'Connaught Place, Delhi', 'Delivered — Received by: Arun Thomas',             '2025-01-09 09:00:00'),
-- Return journey
(45, 17, 'picked_up',       'Connaught Place, Delhi', 'Return pickup completed',                          '2025-01-12 10:00:00'),
(46, 17, 'in_transit',      'Delhi Hub',              'Return shipment dispatched',                       '2025-01-13 08:00:00'),
(47, 17, 'returned_to_origin','Kochi Warehouse',      'Package received at origin warehouse for inspection','2025-01-17 09:00:00'),

-- === Minimal events for remaining delivered shipments ===

-- Shipment 1 (Order 1): Arjun's phone — Kochi local
(48, 1, 'picked_up',  'Kochi Warehouse',        'Package picked up',          '2025-01-16 09:00:00'),
(49, 1, 'delivered',  'Panampilly Nagar, Kochi', 'Delivered to customer',      '2025-01-18 11:00:00'),

-- Shipment 2 (Order 2): Arjun's earbuds+sneaker — Kochi local
(50, 2, 'picked_up',  'Kochi Warehouse',        'Package picked up',          '2025-01-26 09:00:00'),
(51, 2, 'delivered',  'Infopark, Kochi',         'Delivered to customer',      '2025-01-28 16:00:00'),

-- Shipment 4 (Order 4): Vikram's yoga mat
(52, 4, 'picked_up',  'Kochi Warehouse',        'Package picked up',          '2025-01-21 09:00:00'),
(53, 4, 'delivered',  'T Nagar, Chennai',        'Delivered to customer',      '2025-01-23 14:00:00'),

-- Shipment 5 (Order 5): Sneha's shirt
(54, 5, 'picked_up',  'Kochi Warehouse',        'Package picked up',          '2025-01-31 10:00:00'),
(55, 5, 'delivered',  'SG Highway, Ahmedabad',  'Delivered to customer',      '2025-02-04 12:00:00'),

-- Shipment 6 (Order 6): Arun's clothing bundle
(56, 6, 'picked_up',  'Kochi Warehouse',        'Package picked up',          '2025-01-19 08:00:00'),
(57, 6, 'delivered',  'Connaught Place, Delhi',  'Delivered to customer',      '2025-01-24 11:00:00'),

-- Shipment 7 (Order 7): Ananya's denim jacket
(58, 7, 'picked_up',  'Kochi Warehouse',        'Package picked up',          '2025-01-29 11:00:00'),
(59, 7, 'delivered',  'Jubilee Hills, Hyderabad','Delivered to customer',      '2025-02-01 10:00:00'),

-- Shipment 8 (Order 9): Rohan's watch — Bangalore local
(60, 8, 'picked_up',  'Bangalore Warehouse',    'Package picked up',          '2025-02-02 09:00:00'),
(61, 8, 'delivered',  'Koramangala, Bangalore',  'Delivered to customer',      '2025-02-05 16:00:00'),

-- Shipment 9 (Order 10): Fatima's kurti+sunglasses
(62, 9, 'picked_up',  'Kochi Warehouse',        'Package picked up',          '2025-01-26 10:00:00'),
(63, 9, 'delivered',  'MI Road, Jaipur',         'Delivered to customer',      '2025-01-31 14:00:00'),

-- Shipment 10 (Order 11): Siddharth's resistance bands — Kochi local
(64, 10, 'picked_up', 'Kochi Warehouse',        'Package picked up',          '2025-02-02 08:00:00'),
(65, 10, 'delivered', 'Marine Drive, Kochi',     'Delivered to customer',      '2025-02-05 11:00:00'),

-- Shipment 16 (Order 22): Rahul's Runner X — delivered before return
(66, 16, 'picked_up', 'Kochi Warehouse',        'Package picked up',          '2025-02-04 08:00:00'),
(67, 16, 'delivered', 'Warrior Road, Kochi',     'Delivered to customer',      '2025-02-06 14:00:00');


-- ============================================================
-- DELIVERY ESTIMATES (pincode-level)
-- ============================================================
-- Source of truth for CP6: "When will this reach my city?"
-- Diya MUST use this table, not guess.
--
-- Origins:
--   682042 = Kochi warehouse (primary)
--   560001 = Bangalore warehouse (secondary)
--
-- Destinations (all user pincodes from addresses):
--   682036, 682042, 682016, 682030, 682031, 683101 = Kochi area
--   600017, 600086 = Chennai
--   110001 = Delhi
--   122002 = Gurgaon
--   400050, 400051 = Mumbai
--   560025, 560034, 560103, 560001 = Bangalore
--   380015 = Ahmedabad
--   500033 = Hyderabad
--   411004 = Pune
--   302001 = Jaipur
--   700016 = Kolkata
-- ============================================================

INSERT INTO delivery_estimates (estimate_id, origin_pincode, destination_pincode, logistics_partner_id, estimated_days_min, estimated_days_max, is_serviceable) VALUES

-- ===== FROM KOCHI WAREHOUSE (682042) =====

-- Kochi local (same city)
(1,  '682042', '682036', 1, 1, 2, TRUE),    -- Kochi → Kochi (Panampilly Nagar)
(2,  '682042', '682042', 1, 1, 1, TRUE),    -- Kochi → Kochi (Infopark)
(3,  '682042', '682016', 1, 1, 2, TRUE),    -- Kochi → Kochi (Ernakulam)
(4,  '682042', '682030', 1, 1, 2, TRUE),    -- Kochi → Kochi (Kakkanad)
(5,  '682042', '682031', 1, 1, 2, TRUE),    -- Kochi → Kochi (Marine Drive)
(6,  '682042', '683101', 1, 1, 3, TRUE),    -- Kochi → Aluva (slightly further)

-- Kochi → South India
(7,  '682042', '560025', 1, 2, 4, TRUE),    -- Kochi → Bangalore (Residency Rd)
(8,  '682042', '560034', 1, 2, 4, TRUE),    -- Kochi → Bangalore (Koramangala)
(9,  '682042', '560103', 1, 2, 4, TRUE),    -- Kochi → Bangalore (Marathahalli)
(10, '682042', '560001', 1, 2, 4, TRUE),    -- Kochi → Bangalore (Brigade Rd)
(11, '682042', '600017', 1, 2, 4, TRUE),    -- Kochi → Chennai (T Nagar)
(12, '682042', '600086', 1, 2, 4, TRUE),    -- Kochi → Chennai (Gopalapuram)
(13, '682042', '500033', 1, 3, 5, TRUE),    -- Kochi → Hyderabad

-- Kochi → West/North India (Standard, takes longer)
(14, '682042', '400050', 2, 4, 7, TRUE),    -- Kochi → Mumbai (Bandra)
(15, '682042', '400051', 2, 4, 7, TRUE),    -- Kochi → Mumbai (BKC)
(16, '682042', '411004', 2, 4, 6, TRUE),    -- Kochi → Pune
(17, '682042', '380015', 2, 5, 8, TRUE),    -- Kochi → Ahmedabad
(18, '682042', '110001', 2, 5, 8, TRUE),    -- Kochi → Delhi
(19, '682042', '122002', 2, 5, 8, TRUE),    -- Kochi → Gurgaon
(20, '682042', '302001', 2, 5, 9, TRUE),    -- Kochi → Jaipur
(21, '682042', '700016', 2, 6, 10, TRUE),   -- Kochi → Kolkata

-- Non-serviceable example
(22, '682042', '799001', 2, 0, 0, FALSE),   -- Kochi → remote NE India
(23, '682042', '795001', 2, 0, 0, FALSE),   -- Kochi → Nagaland

-- ===== FROM BANGALORE WAREHOUSE (560001) =====

-- Bangalore local
(24, '560001', '560025', 1, 1, 2, TRUE),    -- BLR → BLR (Residency Rd)
(25, '560001', '560034', 1, 1, 2, TRUE),    -- BLR → BLR (Koramangala)
(26, '560001', '560103', 1, 1, 2, TRUE),    -- BLR → BLR (Marathahalli)
(27, '560001', '560001', 1, 1, 1, TRUE),    -- BLR → BLR (Brigade Rd)

-- Bangalore → South India
(28, '560001', '682036', 1, 2, 4, TRUE),    -- BLR → Kochi
(29, '560001', '600017', 1, 2, 3, TRUE),    -- BLR → Chennai
(30, '560001', '600086', 1, 2, 3, TRUE),    -- BLR → Chennai (Gopalapuram)
(31, '560001', '500033', 1, 2, 4, TRUE),    -- BLR → Hyderabad

-- Bangalore → West/North India
(32, '560001', '400050', 2, 3, 5, TRUE),    -- BLR → Mumbai
(33, '560001', '400051', 2, 3, 5, TRUE),    -- BLR → Mumbai (BKC)
(34, '560001', '411004', 2, 3, 5, TRUE),    -- BLR → Pune
(35, '560001', '380015', 2, 4, 6, TRUE),    -- BLR → Ahmedabad
(36, '560001', '110001', 2, 4, 7, TRUE),    -- BLR → Delhi
(37, '560001', '122002', 2, 4, 7, TRUE),    -- BLR → Gurgaon
(38, '560001', '302001', 2, 4, 7, TRUE),    -- BLR → Jaipur
(39, '560001', '700016', 2, 5, 8, TRUE),    -- BLR → Kolkata
(40, '560001', '683101', 1, 2, 4, TRUE);    -- BLR → Aluva
