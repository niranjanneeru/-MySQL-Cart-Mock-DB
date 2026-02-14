-- ============================================================
-- 09_seed_policies.sql
-- Policies — Diya's Source of Truth
-- ============================================================
-- THIS IS THE MOST CRITICAL TABLE FOR THE WORKSHOP.
--
-- CP3 lesson: Diya confidently told a user "refunds take 3-5 days"
-- but that was hallucinated. The real policy was different.
-- Result: user frustration, escalation, trust broken.
--
-- From that point on, Diya MUST:
--   - Quote from this table when answering policy questions
--   - Never make up timelines, rules, or exceptions
--   - Say "let me check our policy" rather than guess
--
-- Each policy has:
--   policy_key:  machine-readable identifier (agent can query by this)
--   content:     the FULL official policy text
--   summary:     short version for quick answers
--   category:    for grouping/filtering
--
-- 13 policies covering all domains
-- ============================================================

USE kvkart;

INSERT INTO policies (policy_id, policy_key, title, category, content, summary, applicable_to, effective_from, effective_until, version, is_active) VALUES

-- ============================================================
-- CANCELLATION POLICIES (2)
-- ============================================================

(1, 'cancellation_before_ship',
 'Order Cancellation — Before Shipping',
 'cancellation',
 'Orders can be cancelled free of charge any time before the order status changes to "shipped". This includes orders in "pending", "confirmed", and "processing" states. Once an order is shipped, cancellation is no longer possible through self-service or through Diya. Users must contact human support for post-shipment issues, which will be treated as a return. COD orders can be cancelled any time until the order status changes to "out_for_delivery". Cancellations are processed immediately and cannot be reversed — once cancelled, the user must place a new order if they change their mind.',
 'Free cancellation before shipping (pending/confirmed/processing). COD cancellable until out-for-delivery. Once shipped, contact support. Cancellations are irreversible.',
 'all', '2024-01-01', NULL, 1, TRUE),

(2, 'cancellation_after_ship',
 'Order Cancellation — After Shipping',
 'cancellation',
 'Once an order has been shipped (status: shipped, in_transit, at_hub, out_for_delivery), it cannot be cancelled through the app or through Diya. The user has two options: (a) Refuse delivery when the package arrives — this triggers an automatic return-to-origin and a refund will be initiated once the item reaches the warehouse. (b) Accept delivery and then raise a return request within the applicable return window. Diya must NOT attempt to cancel a shipped order under any circumstances. Support agents may initiate post-ship cancellations in exceptional cases only, but this requires manager approval and is not guaranteed.',
 'Shipped orders cannot be cancelled. Options: refuse delivery (auto-return) or accept and raise return within window. Diya cannot cancel shipped orders.',
 'all', '2024-01-01', NULL, 1, TRUE),

-- ============================================================
-- RETURN POLICIES (3)
-- ============================================================

(3, 'return_window',
 'Return Policy — Time Window',
 'return',
 'Most products can be returned within 7 days of delivery. Electronics (category: Electronics and all sub-categories) have an extended 10-day return window. Premium members receive a 14-day return window on all eligible categories. The return window is calculated from the "delivered_at" timestamp recorded in the system — not the estimated delivery date or the shipment date. Non-returnable items: books, innerwear, customized/personalized products, and items marked as "final sale". After the return window closes, return requests are automatically rejected and cannot be overridden by Diya or regular support agents.',
 '7-day return window (10 days for electronics, 14 days for premium members). Calculated from delivery date. Non-returnable: books, innerwear, customized items, final sale.',
 'all', '2024-01-01', NULL, 1, TRUE),

(4, 'return_process',
 'Return Process — Steps and Timeline',
 'return',
 'The return process follows these steps: (1) User raises a return request through the app or via Diya, selecting a reason and providing details. (2) The request is reviewed automatically — if the item is within the return window and the category is returnable, it is auto-approved. Edge cases (high-value items above ₹10,000, frequent returners) are flagged for manual review within 24 hours. (3) Once approved, a reverse pickup is scheduled within 2-3 business days. The user will receive a notification with the pickup date and time slot. (4) After pickup, the item is sent to the warehouse for quality inspection (1-2 business days). (5) If inspection passes (item is unused, tags attached, no damage beyond what was reported), refund is initiated. (6) If inspection fails, the return is rejected, and the item is shipped back to the user at no charge. The user will be notified of the rejection reason.',
 'Request → auto-review (24hr for edge cases) → pickup in 2-3 days → warehouse inspection (1-2 days) → refund or rejection. Items must be unused with tags.',
 'all', '2024-01-01', NULL, 1, TRUE),

(5, 'return_non_returnable',
 'Non-Returnable Items',
 'return',
 'The following product categories are non-returnable under any circumstances: (1) Books — once delivered, books cannot be returned unless the wrong book was shipped or the book is physically damaged in transit. (2) Innerwear and swimwear — for hygiene reasons. (3) Customized or personalized products — items made to order. (4) Items marked as "Final Sale" or "Non-Returnable" on the product page. (5) Gift cards and digital products. (6) Products with broken seals where seal integrity is part of the product (e.g., software, security devices). Diya should clearly inform users upfront if an item is non-returnable when they ask about returns.',
 'Non-returnable: books (unless wrong/damaged), innerwear, customized items, final sale, gift cards, digital products, broken-seal items.',
 'all', '2024-01-01', NULL, 1, TRUE),

-- ============================================================
-- REFUND POLICIES (2)
-- ============================================================

(6, 'refund_timeline',
 'Refund Processing Timeline',
 'refund',
 'Refund processing time depends on the original payment method. All timelines are counted from the date the refund is INITIATED in our system — not from the date of the return request or cancellation request. Timeline by method: (1) KV Wallet: Instant — credited immediately upon initiation. (2) UPI (Google Pay, PhonePe, Paytm, BHIM): 2-4 business days. (3) Credit Card: 5-7 business days (may take up to 2 billing cycles to reflect in statement). (4) Debit Card: 5-7 business days. (5) Net Banking: 5-10 business days. (6) Cash on Delivery: Requires user to provide bank account details. Processed via NEFT within 7-10 business days after bank details are confirmed. If bank details are not provided within 30 days, the refund is credited to KV Wallet instead. IMPORTANT: These are business days (Monday-Saturday, excluding public holidays). Diya must never promise faster timelines than listed here.',
 'Wallet: instant. UPI: 2-4 days. Cards: 5-7 days. Net banking: 5-10 days. COD: 7-10 days (needs bank details). All in business days from initiation date. Diya must not promise faster.',
 'all', '2024-01-01', NULL, 1, TRUE),

(7, 'refund_cancellation',
 'Refund for Cancelled Orders',
 'refund',
 'For prepaid orders cancelled before shipping: full refund to the original payment method, initiated immediately upon cancellation. For COD orders cancelled before shipping: no refund is needed as no payment was collected. For prepaid orders where cancellation happens after shipping (via support exception): the refund is processed only after the item is received back at the warehouse and passes inspection. This follows the same timeline as return refunds. Partial cancellations (cancelling one item from a multi-item order): only the cancelled item amount is refunded, shipping fee is not refunded if the remaining items are below the free shipping threshold.',
 'Prepaid before shipping: full refund to original method. COD: no refund needed. Post-ship cancellation: refund after warehouse receives item. Partial cancellation: only cancelled item refunded.',
 'all', '2024-01-01', NULL, 1, TRUE),

-- ============================================================
-- SHIPPING POLICIES (2)
-- ============================================================

(8, 'shipping_delivery',
 'Shipping & Delivery Policy',
 'shipping',
 'KV Kart ships from two warehouse locations: Kochi (pincode 682042) and Bangalore (pincode 560001). The shipping warehouse is selected based on stock availability and proximity to the destination. Delivery estimates are calculated using the delivery_estimates table, which provides pincode-level estimated delivery windows based on the logistics partner assigned. These estimates are NOT guaranteed — actual delivery may vary based on weather, logistics capacity, festivals, strikes, and local conditions. Free standard shipping is available on orders above ₹499. Orders below ₹499 incur a flat ₹49 shipping fee. Express delivery (1-2 day faster than standard) is available for select pincodes at an additional charge of ₹99. Premium members get free express shipping on all orders regardless of order value. Delivery attempts: A maximum of 2 delivery attempts are made. If both fail, the package is returned to the warehouse.',
 'Ships from Kochi/Bangalore. Estimates are pincode-based, NOT guaranteed. Free shipping on ₹499+. Express: ₹99 extra (free for premium). Max 2 delivery attempts.',
 'all', '2024-01-01', NULL, 1, TRUE),

(9, 'shipping_cod',
 'Cash on Delivery Policy',
 'shipping',
 'Cash on Delivery (COD) is available on orders with a total value up to ₹10,000. A COD handling fee of ₹49 is charged on all COD orders. COD is subject to pincode serviceability — not all pincodes support COD (check delivery_estimates.is_serviceable and logistics partner capabilities). COD is not available for the following: orders above ₹10,000, certain high-value electronics, international shipments. COD orders that are refused at the time of delivery will NOT be eligible for re-delivery. The user must place a new order. If a COD order is returned to origin due to delivery failure, no charges are levied on the user.',
 'COD available up to ₹10,000 with ₹49 handling fee. Pincode-dependent. Refused COD orders cannot be re-delivered. No charges for failed delivery returns.',
 'cod', '2024-01-01', NULL, 1, TRUE),

-- ============================================================
-- PAYMENT POLICY (1)
-- ============================================================

(10, 'payment_methods',
 'Accepted Payment Methods',
 'payment',
 'KV Kart accepts the following payment methods: (1) UPI: Google Pay, PhonePe, Paytm, BHIM, and all UPI-enabled bank apps. (2) Credit Cards: Visa, Mastercard, American Express, RuPay. EMI options available on orders above ₹3,000 for select cards (3, 6, 9, 12 month tenures). (3) Debit Cards: All major Indian bank debit cards. (4) Net Banking: 50+ banks supported including SBI, HDFC, ICICI, Axis, Kotak, and more. (5) KV Wallet: Can be topped up via UPI or cards. Maximum wallet balance: ₹20,000. Wallet can be used in combination with other methods for a single order. (6) Cash on Delivery (COD): Subject to order value and pincode limits (see COD policy). Payment processing is handled by our partners Razorpay, PhonePe, and Paytm. All transactions are secured with 256-bit SSL encryption.',
 'Accepts: UPI, credit/debit cards, net banking, KV Wallet (max ₹20K), COD. EMI on credit cards for ₹3000+. Wallet combinable with other methods. Secured via SSL.',
 'all', '2024-01-01', NULL, 1, TRUE),

-- ============================================================
-- ACCOUNT POLICIES (2)
-- ============================================================

(11, 'account_premium',
 'Premium Membership Benefits',
 'account',
 'KV Kart Premium membership is available for ₹999/year. Benefits include: (1) Free express shipping on ALL orders regardless of value. (2) Early access to flash sales — 30 minutes before general users. (3) Exclusive coupon codes (e.g., KVPREMIUM) not available to regular users. (4) Priority customer support — shorter wait times and dedicated support queue. (5) Extended 14-day return window on all eligible categories (instead of standard 7 days). (6) Birthday month special: ₹200 wallet credit in birthday month. Membership auto-renews annually unless cancelled at least 3 days before the expiry date. Cancellation of premium membership is immediate but no prorated refund is provided for the remaining period. Premium benefits apply from the moment of purchase.',
 '₹999/year. Free express shipping, early sale access, exclusive coupons, priority support, 14-day returns, birthday ₹200 credit. Auto-renews. No prorated refund on cancellation.',
 'premium', '2024-01-01', NULL, 1, TRUE),

(12, 'account_suspension',
 'Account Suspension Policy',
 'account',
 'User accounts may be suspended for any of the following reasons: (1) Return abuse: return rate exceeding 50% of orders over any rolling 3-month period. (2) Payment fraud: chargebacks, use of stolen payment instruments, or payment manipulation. (3) Abusive behavior toward support agents or Diya (threats, hate speech, harassment). (4) Violation of KV Kart Terms of Service including but not limited to reselling, bulk buying for commercial purposes without authorization, or review manipulation. Effects of suspension: The user CANNOT place new orders or apply coupons. The user CAN still view their order history, track existing shipments, raise support tickets for existing orders, and request refunds for eligible past orders. Reinstatement process: User must contact support, undergo a review, and may be required to agree to additional terms. Reinstatement is not guaranteed and is at the sole discretion of KV Kart.',
 'Suspended for: >50% return rate, payment fraud, abuse, ToS violations. Cannot place orders. Can view history, track shipments, raise tickets. Reinstatement via support review, not guaranteed.',
 'all', '2024-01-01', NULL, 1, TRUE),

-- ============================================================
-- DIYA SCOPE POLICY (1) — Defines what Diya can and cannot do
-- ============================================================

(13, 'diya_scope',
 'Diya — Scope of Authorized Actions',
 'general',
 'Diya, the AI support assistant, is authorized to perform the following actions: (1) Answer questions about orders, shipments, products, policies, and account details. (2) Look up order status and real-time tracking information from the shipments table. (3) Check refund status and provide expected timelines based on the refund_timeline policy. (4) Initiate order cancellations ONLY for orders that are in cancellable states (pending, confirmed, processing) and where is_cancellable = TRUE. (5) Initiate return requests ONLY for items within the applicable return window and in returnable categories. (6) Provide product recommendations based on catalog search queries (price, category, brand, rating filters). (7) Check coupon validity and eligibility for a user. (8) Provide wallet balance information. (9) Escalate to human support when the request is outside Diya scope.

Diya is NOT authorized to: (a) Override, bend, or make exceptions to any policy — including extending return windows, waiving fees, or granting ineligible discounts. (b) Process manual discounts or price adjustments. (c) Cancel orders that are already shipped, out for delivery, or delivered. (d) Modify order details (address, items, payment method) after placement. (e) Access, display, or modify payment instruments (card numbers, bank details, UPI IDs). (f) Make promises about delivery dates beyond what the delivery_estimates table and shipment tracking provide. (g) Approve return requests that fall outside the return window. (h) Reinstate suspended accounts. (i) Process refunds directly — Diya can only check refund status.

When a request falls outside Diya scope, she must clearly say so and offer to escalate to human support. She must never attempt an unauthorized action or give the impression that she might be able to make an exception.',
 'Diya CAN: answer queries, track orders, check refunds, cancel eligible orders, initiate eligible returns, search products, check coupons, check wallet, escalate. Diya CANNOT: override policies, grant discounts, cancel shipped orders, modify orders, access payment details, promise delivery dates, approve out-of-window returns, reinstate accounts, process refunds.',
 'all', '2025-01-01', NULL, 1, TRUE);
