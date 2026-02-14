# KV Kart Database — Diya AI Support Assistant Workshop

## Quick Start

```bash
# First run: builds image + initializes DB from SQL files (~30-60 seconds)
docker compose up -d --build

# Subsequent runs: starts instantly from persisted volume (~5 seconds)
docker compose up -d
```

## Connection Details

| Field    | Value           |
|----------|-----------------|
| Host     | `localhost`     |
| Port     | `3306`          |
| Database | `kvkart`        |
| User     | `diya`          |
| Password | `diya_password` |

Root access (if needed):
- User: `root`
- Password: `kvkart_root`

### Connection String

```
mysql://diya:diya_password@localhost:3306/kvkart
```

### Connect via CLI

```bash
# Using docker exec
docker exec -it kvkart-db mysql -u diya -pdiya_password kvkart

# Using local mysql client
mysql -h 127.0.0.1 -P 3306 -u diya -pdiya_password kvkart
```

### Connect from Python

```python
import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    port=3306,
    user="diya",
    password="diya_password",
    database="kvkart"
)
cursor = conn.cursor(dictionary=True)
cursor.execute("SELECT first_name, last_name FROM users WHERE user_id = 1")
print(cursor.fetchone())  # {'first_name': 'Arjun', 'last_name': 'Menon'}
```

## How Persistence Works

- **First run**: MySQL detects an empty data volume → runs all `*.sql` files in `/docker-entrypoint-initdb.d/` alphabetically → writes initialized DB to the volume.
- **Every run after that**: MySQL detects existing data in the volume → **skips all init scripts** → starts the server directly. This means startup is near-instant.

## Useful Commands

```bash
# Start the database
docker compose up -d

# Check if it's healthy
docker compose ps

# View logs (useful during first-time init)
docker compose logs -f kvkart-db

# Stop the database (data persists)
docker compose down

# Full reset: destroy volume + rebuild from scratch
docker compose down -v
docker compose up -d --build

# Quick test query
docker exec -it kvkart-db mysql -u diya -pdiya_password kvkart -e "SELECT COUNT(*) as total_users FROM users;"
```

## Database Overview

| Table                    | Rows | Purpose                                  |
|--------------------------|------|------------------------------------------|
| users                    | 15   | Customer accounts                        |
| addresses                | 21   | Shipping addresses                       |
| categories               | 18   | Product category hierarchy               |
| brands                   | 10   | Product brands                           |
| products                 | 38   | Product catalog                          |
| product_images           | 47   | Product photos                           |
| orders                   | 25   | Order lifecycle                          |
| order_items              | 30   | Line items per order                     |
| logistics_partners       | 4    | Shipping carriers (KVFast, BlueDart...) |
| shipments                | 18   | Shipment tracking                        |
| shipment_tracking_events | 67   | Granular tracking history                |
| delivery_estimates       | 40   | Pincode-level delivery timelines         |
| return_requests          | 3    | Return lifecycle                         |
| refunds                  | 3    | Refund processing                        |
| payments                 | 25   | Payment records                          |
| wallet                   | 15   | User wallet balances                     |
| wallet_transactions      | 11   | Wallet activity log                      |
| coupons                  | 8    | Discount codes with eligibility rules    |
| coupon_usage             | 3    | Coupon redemption history                |
| product_reviews          | 14   | Customer reviews                         |
| policies                 | 13   | **Diya's source of truth**               |
| support_tickets          | 8    | Escalation cases                         |
| notifications            | 30   | User notifications                       |
| wishlists                | 15   | Saved items                              |
| cart_items               | 8    | Active shopping carts                    |

**Total: 25 tables, ~400+ rows of interconnected mock data**

## Key Test Queries for Your Agent

```sql
-- "Where is my order?" (Priya, user 5)
SELECT o.order_number, o.order_status, s.shipment_status, s.last_location, s.estimated_delivery_date
FROM orders o
JOIN shipments s ON o.order_id = s.order_id
WHERE o.user_id = 5 AND o.order_status NOT IN ('delivered', 'cancelled', 'returned');

-- "Show me shoes under 2000"
SELECT p.name, p.selling_price, b.name as brand
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
WHERE (c.name LIKE '%Footwear%' OR p.tags LIKE '%shoes%')
  AND p.selling_price < 2000
  AND p.is_active = TRUE;

-- "How long does a refund take?" → Query the policy, don't hallucinate!
SELECT summary FROM policies WHERE policy_key = 'refund_timeline' AND is_active = TRUE;

-- "Can I cancel my order?" (check eligibility first!)
SELECT order_number, order_status, is_cancellable
FROM orders
WHERE user_id = 8 AND order_status NOT IN ('delivered', 'cancelled', 'returned');

-- "When will my order reach Hyderabad?"
SELECT de.estimated_days_min, de.estimated_days_max, lp.name as carrier
FROM delivery_estimates de
JOIN logistics_partners lp ON de.logistics_partner_id = lp.partner_id
WHERE de.origin_pincode = '682042' AND de.destination_pincode = '500033';
```
