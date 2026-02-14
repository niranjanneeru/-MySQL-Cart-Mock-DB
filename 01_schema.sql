-- ============================================================
-- KV Kart — Schema Only (No Data)
-- Workshop: Building Diya, the AI Support Assistant
-- ============================================================

CREATE DATABASE IF NOT EXISTS kvkart;
USE kvkart;

-- ============================================================
-- 1. users
-- CP2: Personalized greetings, returning vs new user detection
-- ============================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say') DEFAULT 'prefer_not_to_say',
    account_status ENUM('active', 'suspended', 'deactivated') DEFAULT 'active',
    is_premium_member BOOLEAN DEFAULT FALSE,
    premium_expiry DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. addresses
-- CP4,6: Shipping destination → delivery estimates
-- ============================================================
CREATE TABLE addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    label VARCHAR(30) DEFAULT 'home',
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address_line1 VARCHAR(200) NOT NULL,
    address_line2 VARCHAR(200),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    country VARCHAR(50) DEFAULT 'India',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 3. categories (self-referencing hierarchy)
-- CP4: "Show me shoes" → browsing by category
-- ============================================================
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT DEFAULT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- ============================================================
-- 4. brands
-- CP4: Product filtering by brand
-- ============================================================
CREATE TABLE brands (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    logo_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- 5. products
-- CP4: "Shoes under 2000" → catalog search
-- ============================================================
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    brand_id INT,
    category_id INT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    stock_quantity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    average_rating DECIMAL(3,2) DEFAULT 0,
    total_ratings INT DEFAULT 0,
    weight_grams INT DEFAULT NULL,
    tags VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ============================================================
-- 6. product_images
-- Visual context for products
-- ============================================================
CREATE TABLE product_images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- 7. orders
-- CP4,5,7: Order lookups, cancellation, eligibility checks
-- ============================================================
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    order_status ENUM(
        'pending',
        'confirmed',
        'processing',
        'shipped',
        'out_for_delivery',
        'delivered',
        'cancelled',
        'return_requested',
        'returned',
        'failed'
    ) NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    shipping_fee DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    coupon_code VARCHAR(30) DEFAULT NULL,
    payment_method ENUM('upi', 'credit_card', 'debit_card', 'net_banking', 'wallet', 'cod') NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refund_initiated', 'refunded') DEFAULT 'pending',
    is_cancellable BOOLEAN DEFAULT TRUE,
    cancellation_reason VARCHAR(500) DEFAULT NULL,
    cancelled_at TIMESTAMP NULL DEFAULT NULL,
    placed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP NULL DEFAULT NULL,
    shipped_at TIMESTAMP NULL DEFAULT NULL,
    delivered_at TIMESTAMP NULL DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id)
);

-- ============================================================
-- 8. order_items
-- CP4: Line-level detail — "What did I order?"
-- ============================================================
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    item_status ENUM('active', 'cancelled', 'returned') DEFAULT 'active',
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- 9. logistics_partners
-- CP6: Different carriers, different speeds
-- ============================================================
CREATE TABLE logistics_partners (
    partner_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    tracking_url_template VARCHAR(500),
    avg_delivery_days INT DEFAULT 5,
    is_active BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- 10. shipments
-- CP6,7: Real tracking tied to logistics system
-- ============================================================
CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    logistics_partner_id INT NOT NULL,
    awb_number VARCHAR(50) UNIQUE NOT NULL,
    shipment_status ENUM(
        'label_created',
        'picked_up',
        'in_transit',
        'at_hub',
        'out_for_delivery',
        'delivered',
        'failed_attempt',
        'returned_to_origin'
    ) DEFAULT 'label_created',
    origin_city VARCHAR(100) NOT NULL,
    destination_city VARCHAR(100) NOT NULL,
    destination_pincode VARCHAR(10) NOT NULL,
    estimated_delivery_date DATE NOT NULL,
    actual_delivery_date DATE DEFAULT NULL,
    weight_grams INT DEFAULT NULL,
    last_location VARCHAR(200) DEFAULT NULL,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (logistics_partner_id) REFERENCES logistics_partners(partner_id)
);

-- ============================================================
-- 11. shipment_tracking_events
-- CP6: Granular tracking history
-- ============================================================
CREATE TABLE shipment_tracking_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    shipment_id INT NOT NULL,
    event_status VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    description VARCHAR(500),
    event_timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

-- ============================================================
-- 12. delivery_estimates
-- CP6: Pincode-level estimates (KVFast source of truth)
-- ============================================================
CREATE TABLE delivery_estimates (
    estimate_id INT PRIMARY KEY AUTO_INCREMENT,
    origin_pincode VARCHAR(10) NOT NULL,
    destination_pincode VARCHAR(10) NOT NULL,
    logistics_partner_id INT NOT NULL,
    estimated_days_min INT NOT NULL,
    estimated_days_max INT NOT NULL,
    is_serviceable BOOLEAN DEFAULT TRUE,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (logistics_partner_id) REFERENCES logistics_partners(partner_id)
);

-- ============================================================
-- 13. return_requests
-- CP7: Return lifecycle with eligibility tracking
-- ============================================================
CREATE TABLE return_requests (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    user_id INT NOT NULL,
    reason ENUM(
        'defective',
        'wrong_item',
        'not_as_described',
        'size_issue',
        'changed_mind',
        'arrived_late',
        'other'
    ) NOT NULL,
    reason_detail TEXT,
    return_status ENUM(
        'requested',
        'approved',
        'pickup_scheduled',
        'picked_up',
        'received_at_warehouse',
        'inspected',
        'refund_initiated',
        'refund_completed',
        'rejected'
    ) DEFAULT 'requested',
    pickup_date DATE DEFAULT NULL,
    rejection_reason VARCHAR(500) DEFAULT NULL,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 14. refunds
-- CP3: Real refund timelines — Diya must quote, not guess
-- ============================================================
CREATE TABLE refunds (
    refund_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    return_id INT DEFAULT NULL,
    user_id INT NOT NULL,
    refund_type ENUM('cancellation', 'return', 'price_adjustment', 'goodwill') NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    refund_method ENUM('original_payment', 'wallet', 'bank_transfer') NOT NULL,
    refund_status ENUM('initiated', 'processing', 'completed', 'failed') DEFAULT 'initiated',
    expected_completion_date DATE NOT NULL,
    actual_completion_date DATE DEFAULT NULL,
    transaction_reference VARCHAR(100) DEFAULT NULL,
    initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (return_id) REFERENCES return_requests(return_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 15. payments
-- CP8: Payment tracking — Diya cannot modify these
-- ============================================================
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    payment_method ENUM('upi', 'credit_card', 'debit_card', 'net_banking', 'wallet', 'cod') NOT NULL,
    payment_gateway VARCHAR(50) DEFAULT NULL,
    transaction_id VARCHAR(100) UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(5) DEFAULT 'INR',
    payment_status ENUM('initiated', 'success', 'failed', 'refunded') DEFAULT 'initiated',
    paid_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 16. wallet
-- CP8: User wallet balance
-- ============================================================
CREATE TABLE wallet (
    wallet_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    balance DECIMAL(10,2) DEFAULT 0.00,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 17. wallet_transactions
-- Refund credits, cashback, purchases via wallet
-- ============================================================
CREATE TABLE wallet_transactions (
    txn_id INT PRIMARY KEY AUTO_INCREMENT,
    wallet_id INT NOT NULL,
    txn_type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description VARCHAR(300),
    reference_type ENUM('refund', 'cashback', 'purchase', 'promotional', 'topup') NOT NULL,
    reference_id VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wallet_id) REFERENCES wallet(wallet_id)
);

-- ============================================================
-- 18. coupons
-- CP8: "Give me a discount" — strict eligibility rules
-- ============================================================
CREATE TABLE coupons (
    coupon_id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(300) NOT NULL,
    discount_type ENUM('percentage', 'flat') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) DEFAULT 0,
    max_discount_amount DECIMAL(10,2) DEFAULT NULL,
    applicable_categories VARCHAR(200) DEFAULT NULL,
    applicable_user_type ENUM('all', 'new', 'premium') DEFAULT 'all',
    usage_limit_total INT DEFAULT NULL,
    usage_limit_per_user INT DEFAULT 1,
    times_used INT DEFAULT 0,
    valid_from DATETIME NOT NULL,
    valid_until DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 19. coupon_usage
-- CP8: Who used what, enforce limits
-- ============================================================
CREATE TABLE coupon_usage (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_applied DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- 20. product_reviews
-- CP4: Product quality context for recommendations
-- ============================================================
CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    body TEXT,
    is_verified_purchase BOOLEAN DEFAULT TRUE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- 21. policies
-- CP3: Diya's source of truth — MUST quote, NEVER invent
-- ============================================================
CREATE TABLE policies (
    policy_id INT PRIMARY KEY AUTO_INCREMENT,
    policy_key VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    category ENUM('cancellation', 'return', 'refund', 'shipping', 'payment', 'account', 'general') NOT NULL,
    content TEXT NOT NULL,
    summary VARCHAR(500) NOT NULL,
    applicable_to ENUM('all', 'premium', 'cod', 'prepaid') DEFAULT 'all',
    effective_from DATE NOT NULL,
    effective_until DATE DEFAULT NULL,
    version INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 22. support_tickets
-- CP8: Escalation path when Diya can't help
-- ============================================================
CREATE TABLE support_tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    order_id INT DEFAULT NULL,
    category ENUM(
        'order_issue',
        'delivery_issue',
        'return_refund',
        'payment_issue',
        'product_complaint',
        'account_issue',
        'general_inquiry',
        'escalation'
    ) NOT NULL,
    subject VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'waiting_on_customer', 'resolved', 'closed') DEFAULT 'open',
    assigned_agent VARCHAR(100) DEFAULT NULL,
    source ENUM('diya_escalation', 'user_created', 'system') DEFAULT 'diya_escalation',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- 23. notifications
-- Delivery alerts, refund updates, promo notifications
-- ============================================================
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM(
        'order_confirmed',
        'order_shipped',
        'out_for_delivery',
        'order_delivered',
        'order_cancelled',
        'return_approved',
        'return_rejected',
        'refund_initiated',
        'refund_completed',
        'payment_failed',
        'promo',
        'price_drop',
        'back_in_stock',
        'delivery_delayed',
        'account_alert'
    ) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    reference_type VARCHAR(50) DEFAULT NULL,   -- 'order', 'return', 'refund', 'product', etc.
    reference_id INT DEFAULT NULL,              -- the id of the referenced entity
    channel ENUM('in_app', 'email', 'sms', 'push') DEFAULT 'in_app',
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 24. wishlists
-- CP2: User interest context
-- ============================================================
CREATE TABLE wishlists (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- 25. cart_items
-- CP2,5: Current cart — context for "I might want to cancel"
-- ============================================================
CREATE TABLE cart_items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
