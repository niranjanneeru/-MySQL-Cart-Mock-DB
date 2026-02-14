-- ============================================================
-- 03_seed_catalog.sql
-- Categories + Brands + Products + Product Images
-- ============================================================
-- Design rationale:
--   - 2-level category hierarchy (parent → child)
--   - 10 brands across segments
--   - 35 products spread across categories and price ranges
--   - Price range: ₹299 to ₹74,999 (tests "under X" queries)
--   - Some out-of-stock items (stock_quantity = 0)
--   - Some inactive products (is_active = FALSE)
--   - Tags for flexible search ("shoes,running,lightweight")
--   - Products designed to match narrative queries:
--       "shoes under 2000" → multiple results
--       "show me laptops" → 3 options at different price points
--       Category browsing, brand filtering, price sorting
-- ============================================================

USE kvkart;

-- ============================================================
-- CATEGORIES (2-level hierarchy)
-- ============================================================
-- IDs 1-5: Parent categories
-- IDs 6+:  Child categories

INSERT INTO categories (category_id, name, parent_category_id, description, is_active) VALUES
-- Parent categories
(1,  'Electronics',      NULL, 'Electronic devices and accessories',          TRUE),
(2,  'Fashion',          NULL, 'Clothing, footwear, and accessories',         TRUE),
(3,  'Home & Kitchen',   NULL, 'Home appliances and kitchen essentials',      TRUE),
(4,  'Books',            NULL, 'Books, ebooks, and educational material',     TRUE),
(5,  'Sports & Fitness', NULL, 'Sports equipment and fitness gear',           TRUE),

-- Electronics children
(6,  'Mobile Phones',       1, 'Smartphones and basic phones',               TRUE),
(7,  'Laptops',             1, 'Laptops and notebooks',                      TRUE),
(8,  'Headphones & Audio',  1, 'Earphones, headphones, TWS, and speakers',   TRUE),
(9,  'Mobile Accessories',  1, 'Cases, chargers, screen guards',             TRUE),

-- Fashion children
(10, 'Men Footwear',        2, 'Shoes, sandals, and slippers for men',       TRUE),
(11, 'Women Footwear',      2, 'Shoes, heels, and sandals for women',        TRUE),
(12, 'Men Clothing',        2, 'Shirts, t-shirts, and trousers for men',     TRUE),
(13, 'Women Clothing',      2, 'Dresses, tops, and ethnic wear for women',   TRUE),
(14, 'Accessories',         2, 'Watches, bags, belts, sunglasses',           TRUE),

-- Home & Kitchen children
(15, 'Kitchen Appliances',  3, 'Mixers, kettles, air fryers, ovens',         TRUE),
(16, 'Home Decor',          3, 'Lamps, clocks, wall art, cushions',          TRUE),

-- Sports & Fitness children
(17, 'Gym & Fitness',       5, 'Gym equipment, yoga mats, weights',          TRUE),
(18, 'Outdoor & Adventure', 5, 'Hiking, camping, cycling gear',              TRUE);

-- ============================================================
-- BRANDS (10 brands)
-- ============================================================

INSERT INTO brands (brand_id, name, logo_url, is_active) VALUES
(1,  'KVTech',        'https://kvkart.in/brands/kvtech.png',        TRUE),
(2,  'UrbanStep',     'https://kvkart.in/brands/urbanstep.png',     TRUE),
(3,  'FitLife',       'https://kvkart.in/brands/fitlife.png',        TRUE),
(4,  'BookWorm',      'https://kvkart.in/brands/bookworm.png',       TRUE),
(5,  'HomeChef',      'https://kvkart.in/brands/homechef.png',       TRUE),
(6,  'StyleQueen',    'https://kvkart.in/brands/stylequeen.png',     TRUE),
(7,  'SoundWave',     'https://kvkart.in/brands/soundwave.png',      TRUE),
(8,  'PowerGear',     'https://kvkart.in/brands/powergear.png',      TRUE),
(9,  'ClassicWear',   'https://kvkart.in/brands/classicwear.png',    TRUE),
(10, 'TrendSetters',  'https://kvkart.in/brands/trendsetters.png',   TRUE);

-- ============================================================
-- PRODUCTS (35 products)
-- ============================================================
-- Spread:
--   Electronics: 9 products (phones, laptops, audio, accessories)
--   Fashion:    13 products (men/women footwear, clothing, accessories)
--   Home:        5 products (kitchen appliances, decor)
--   Books:       3 products
--   Sports:      5 products (gym, outdoor)
-- Edge cases:
--   Product 33: out of stock (stock_quantity = 0)
--   Product 34: inactive (is_active = FALSE, discontinued)
--   Product 35: very expensive (₹74,999 — tests high-value order scenarios)
-- ============================================================

INSERT INTO products (product_id, name, description, brand_id, category_id, base_price, selling_price, discount_percent, stock_quantity, is_active, average_rating, total_ratings, weight_grams, tags) VALUES

-- ===== ELECTRONICS — MOBILE PHONES (cat 6) =====
(1,  'KVTech Nova 12 Pro',
     '6.7" AMOLED display, 128GB storage, 5G enabled, 50MP triple camera, 5000mAh battery',
     1, 6, 24999.00, 21999.00, 12.00, 150, TRUE, 4.30, 2450, 185,
     'smartphone,5g,amoled,flagship,128gb'),

(2,  'KVTech Lite X',
     '6.5" IPS LCD, 64GB storage, 4G, 13MP dual camera, 4500mAh battery. Best budget phone under 10K.',
     1, 6, 11999.00, 9999.00, 16.67, 300, TRUE, 4.00, 1820, 175,
     'smartphone,budget,4g,value,64gb'),

(3,  'KVTech Nova 12 SE',
     '6.5" AMOLED, 128GB, 5G, 32MP camera, 4800mAh. Mid-range performer.',
     1, 6, 17999.00, 15999.00, 11.11, 200, TRUE, 4.15, 1100, 180,
     'smartphone,5g,amoled,midrange,128gb'),

-- ===== ELECTRONICS — LAPTOPS (cat 7) =====
(4,  'PowerGear UltraBook 14',
     '14" FHD IPS, Intel i5-13th Gen, 16GB RAM, 512GB SSD, fingerprint reader, backlit keyboard',
     8, 7, 72999.00, 64999.00, 10.96, 45, TRUE, 4.50, 680, 1400,
     'laptop,ultrabook,i5,work,programming,16gb'),

(5,  'KVTech ChromeBook Edu',
     '11.6" HD, MediaTek processor, 4GB RAM, 64GB eMMC, Chrome OS. Ideal for students.',
     1, 7, 21999.00, 18999.00, 13.64, 120, TRUE, 3.80, 340, 1200,
     'laptop,chromebook,student,budget,education'),

(6,  'PowerGear ProBook 16',
     '16" 2.5K IPS, Intel i7-13th Gen, 32GB RAM, 1TB SSD, RTX 3050. Creator and dev machine.',
     8, 7, 109999.00, 94999.00, 13.64, 25, TRUE, 4.70, 320, 2100,
     'laptop,i7,creator,programming,32gb,gaming'),

-- ===== ELECTRONICS — HEADPHONES & AUDIO (cat 8) =====
(7,  'SoundWave AirBuds Pro',
     'True wireless ANC earbuds, 30hr total battery, IPX5 water resistant, low-latency gaming mode',
     7, 8, 4999.00, 3499.00, 30.01, 500, TRUE, 4.40, 5200, 52,
     'tws,anc,earbuds,wireless,ipx5'),

(8,  'SoundWave OverEar 500',
     'Over-ear headphones, Hi-Res Audio certified, ANC, 40hr battery, foldable, plush cushions',
     7, 8, 8999.00, 7499.00, 16.67, 100, TRUE, 4.60, 1100, 280,
     'headphones,overear,hifi,anc,wireless'),

(9,  'SoundWave Bass Cannon',
     'Portable Bluetooth speaker, 20W output, deep bass, IPX7, 12hr battery, USB-C',
     7, 8, 3499.00, 2799.00, 20.01, 180, TRUE, 4.20, 1800, 600,
     'speaker,bluetooth,portable,bass,waterproof'),

-- ===== ELECTRONICS — MOBILE ACCESSORIES (cat 9) =====
(10, 'KVTech 65W GaN Charger',
     '65W GaN USB-C charger, dual port (USB-C + USB-A), compact foldable plug, works with phones and laptops',
     1, 9, 2499.00, 1899.00, 24.01, 350, TRUE, 4.35, 920, 120,
     'charger,gan,65w,usbc,fast-charging'),

-- ===== FASHION — MEN FOOTWEAR (cat 10) =====
(11, 'UrbanStep Runner X',
     'Lightweight running shoes, breathable mesh upper, EVA midsole, rubber outsole',
     2, 10, 3999.00, 2799.00, 30.01, 200, TRUE, 4.20, 3100, 320,
     'shoes,running,lightweight,sports,mesh'),

(12, 'UrbanStep Classic Loafer',
     'Genuine leather loafers, cushioned insole, formal and semi-formal',
     2, 10, 4599.00, 3999.00, 13.05, 80, TRUE, 4.10, 890, 380,
     'shoes,formal,leather,loafer,office'),

(13, 'UrbanStep Daily Sneaker',
     'Canvas sneakers, casual everyday wear, lace-up, padded collar',
     2, 10, 1999.00, 1499.00, 25.01, 350, TRUE, 4.00, 4200, 300,
     'shoes,casual,sneaker,canvas,daily'),

(14, 'UrbanStep Trail Blazer',
     'Hiking shoes, waterproof membrane, ankle support, Vibram outsole',
     2, 10, 5999.00, 4999.00, 16.67, 60, TRUE, 4.50, 450, 520,
     'shoes,hiking,waterproof,outdoor,trekking'),

(15, 'UrbanStep Flip Comfort',
     'Daily wear flip-flops, soft EVA footbed, textured grip, ultra-light',
     2, 10, 599.00, 449.00, 25.04, 500, TRUE, 3.90, 6200, 150,
     'flipflops,casual,daily,eva,light'),

-- ===== FASHION — WOMEN FOOTWEAR (cat 11) =====
(16, 'UrbanStep Ballet Flat',
     'Faux leather ballet flats, cushioned insole, flexible sole, office and casual',
     2, 11, 1799.00, 1299.00, 27.79, 160, TRUE, 4.10, 1100, 220,
     'shoes,ballet,flat,casual,office'),

(17, 'StyleQueen Block Heels',
     '3-inch block heels, suede finish, buckle strap, party and formal wear',
     6, 11, 2999.00, 2399.00, 20.01, 90, TRUE, 4.30, 650, 350,
     'heels,block,suede,party,formal'),

-- ===== FASHION — MEN CLOTHING (cat 12) =====
(18, 'ClassicWear Oxford Shirt',
     '100% cotton oxford shirt, slim fit, button-down collar, chest pocket',
     9, 12, 1999.00, 1599.00, 20.01, 200, TRUE, 4.20, 2100, 180,
     'shirt,cotton,formal,slim,oxford'),

(19, 'ClassicWear Chinos',
     'Stretch cotton chinos, tapered fit, wrinkle-free finish, 4 pockets',
     9, 12, 2499.00, 1999.00, 20.01, 150, TRUE, 4.30, 1800, 320,
     'trousers,chinos,casual,stretch,tapered'),

(20, 'FitLife Dry-Fit Tee',
     'Moisture-wicking polyester sports t-shirt, raglan sleeve, reflective logo',
     3, 12, 899.00, 699.00, 22.25, 400, TRUE, 4.00, 3500, 120,
     'tshirt,sports,dryfit,gym,moisture-wicking'),

-- ===== FASHION — WOMEN CLOTHING (cat 13) =====
(21, 'StyleQueen Floral Kurti',
     'Cotton floral print kurti, A-line cut, calf length, side slits, perfect for daily wear',
     6, 13, 1499.00, 1099.00, 26.68, 180, TRUE, 4.30, 1560, 200,
     'kurti,cotton,floral,ethnic,aline'),

(22, 'StyleQueen Denim Jacket',
     'Oversized denim jacket, medium wash, button closure, two chest pockets, versatile layering piece',
     6, 13, 2999.00, 2499.00, 16.67, 100, TRUE, 4.40, 780, 450,
     'jacket,denim,casual,winter,oversized'),

(23, 'TrendSetters Maxi Dress',
     'Georgette maxi dress, solid pastel shades, V-neck, flared hem, occasion wear',
     10, 13, 2499.00, 1899.00, 24.01, 120, TRUE, 4.10, 1200, 250,
     'dress,maxi,georgette,party,pastel'),

-- ===== FASHION — ACCESSORIES (cat 14) =====
(24, 'TrendSetters Analog Watch',
     'Stainless steel case, water resistant 50m, genuine leather strap, Japanese quartz movement',
     10, 14, 3999.00, 2999.00, 25.01, 70, TRUE, 4.30, 520, 85,
     'watch,analog,leather,classic,quartz'),

(25, 'TrendSetters Laptop Backpack',
     '30L capacity, water-resistant fabric, padded laptop sleeve (fits 15.6"), USB charging port, anti-theft pocket',
     10, 14, 2499.00, 1799.00, 28.01, 130, TRUE, 4.40, 2100, 750,
     'backpack,laptop,travel,waterproof,30l'),

(26, 'StyleQueen Sunglasses UV400',
     'Polarized lenses, UV400 protection, cat-eye frame, lightweight acetate, comes with hard case',
     6, 14, 1999.00, 1499.00, 25.01, 200, TRUE, 4.10, 1300, 30,
     'sunglasses,uv400,polarized,cateye,fashion'),

-- ===== HOME & KITCHEN — KITCHEN APPLIANCES (cat 15) =====
(27, 'HomeChef Air Fryer 4.5L',
     'Digital air fryer, 4.5L capacity, 8 presets, 360° rapid air, non-stick basket, touch panel',
     5, 15, 6999.00, 5499.00, 21.43, 75, TRUE, 4.50, 2800, 4500,
     'airfryer,kitchen,cooking,healthy,digital'),

(28, 'HomeChef Electric Kettle 1.5L',
     '1.5L stainless steel kettle, 1500W fast boil, auto shut-off, boil-dry protection, cool-touch handle',
     5, 15, 1499.00, 1199.00, 20.01, 250, TRUE, 4.20, 4100, 800,
     'kettle,electric,kitchen,tea,steel'),

(29, 'HomeChef Mixer Grinder 750W',
     '3 stainless steel jars, 750W copper motor, 3-speed control, overload protection',
     5, 15, 4999.00, 3999.00, 20.00, 100, TRUE, 4.40, 1900, 3500,
     'mixer,grinder,kitchen,indian,750w'),

-- ===== HOME & KITCHEN — HOME DECOR (cat 16) =====
(30, 'HomeChef Bamboo Table Lamp',
     'Handcrafted bamboo shade, warm LED bulb included, wooden base, ambient bedroom lighting',
     5, 16, 1899.00, 1499.00, 21.06, 60, TRUE, 4.25, 340, 900,
     'lamp,bamboo,decor,bedroom,ambient'),

-- ===== BOOKS (cat 4) =====
(31, 'Mastering Python',
     'Complete guide to Python programming — from basics to advanced. Covers OOP, web dev, data science. 3rd edition, 650 pages.',
     4, 4, 799.00, 599.00, 25.03, 500, TRUE, 4.60, 920, 450,
     'book,python,programming,tech,beginner'),

(32, 'The Startup Way',
     'Building an entrepreneurial mindset in large organizations. Real case studies from Fortune 500 companies. 320 pages.',
     4, 4, 499.00, 399.00, 20.04, 300, TRUE, 4.20, 640, 320,
     'book,startup,business,entrepreneurship,management'),

(33, 'Indian Art & Culture',
     'A comprehensive illustrated guide to India''s art heritage — architecture, painting, sculpture, and performing arts. 280 pages.',
     4, 4, 350.00, 299.00, 14.57, 0, TRUE, 4.10, 380, 280,
     'book,art,culture,india,heritage'),
-- ^^^ OUT OF STOCK (stock_quantity = 0) — tests "back in stock" notification scenario

-- ===== SPORTS & FITNESS — GYM & FITNESS (cat 17) =====
(34, 'FitLife Yoga Mat 6mm',
     'Anti-slip TPE material, 6mm thick, 183cm x 61cm, alignment lines, carry strap included',
     3, 17, 1299.00, 999.00, 23.09, 180, TRUE, 4.30, 2200, 1200,
     'yoga,mat,fitness,antislip,tpe'),

(35, 'FitLife Resistance Bands Set',
     '5-band set with varying resistance (10-50 lbs), latex-free TPE, door anchor and carry bag included',
     3, 17, 999.00, 749.00, 25.03, 220, TRUE, 4.40, 1800, 300,
     'resistance,bands,gym,home,workout'),

(36, 'FitLife Dumbbells 5kg Pair',
     'Rubber-coated hex dumbbells, 5kg each, anti-roll flat edges, chrome-plated handle, sold as pair',
     3, 17, 1999.00, 1699.00, 15.01, 100, TRUE, 4.50, 950, 10000,
     'dumbbells,weights,gym,strength,rubber'),

-- ===== SPORTS & FITNESS — OUTDOOR (cat 18) =====
(37, 'FitLife Hydration Backpack 2L',
     '2L water bladder, 10L storage, breathable mesh back panel, chest and waist straps, ideal for trail running',
     3, 18, 2999.00, 2499.00, 16.67, 45, TRUE, 4.35, 280, 400,
     'backpack,hydration,trail,running,outdoor'),

-- ===== EDGE CASE: DISCONTINUED PRODUCT =====
(38, 'KVTech Nova 10 (Discontinued)',
     '6.1" LCD, 64GB, 4G. Previous generation phone. No longer in production.',
     1, 6, 14999.00, 9999.00, 33.34, 12, FALSE, 3.50, 4500, 170,
     'smartphone,4g,old,discontinued');
-- ^^^ is_active = FALSE — tests catalog filtering


-- ============================================================
-- PRODUCT IMAGES
-- ============================================================
-- At least 1 primary image per active product
-- Popular products get 2-3 images
-- ============================================================

INSERT INTO product_images (image_id, product_id, image_url, is_primary, sort_order) VALUES
-- Phones
(1,  1,  'https://kvkart.in/images/products/nova12pro_front.jpg',      TRUE,  1),
(2,  1,  'https://kvkart.in/images/products/nova12pro_back.jpg',       FALSE, 2),
(3,  1,  'https://kvkart.in/images/products/nova12pro_side.jpg',       FALSE, 3),
(4,  2,  'https://kvkart.in/images/products/litex_front.jpg',          TRUE,  1),
(5,  2,  'https://kvkart.in/images/products/litex_back.jpg',           FALSE, 2),
(6,  3,  'https://kvkart.in/images/products/nova12se_front.jpg',       TRUE,  1),

-- Laptops
(7,  4,  'https://kvkart.in/images/products/ultrabook14_open.jpg',     TRUE,  1),
(8,  4,  'https://kvkart.in/images/products/ultrabook14_closed.jpg',   FALSE, 2),
(9,  5,  'https://kvkart.in/images/products/chromebook_edu.jpg',       TRUE,  1),
(10, 6,  'https://kvkart.in/images/products/probook16_open.jpg',       TRUE,  1),
(11, 6,  'https://kvkart.in/images/products/probook16_side.jpg',       FALSE, 2),

-- Audio
(12, 7,  'https://kvkart.in/images/products/airbudspro_case.jpg',      TRUE,  1),
(13, 7,  'https://kvkart.in/images/products/airbudspro_buds.jpg',      FALSE, 2),
(14, 8,  'https://kvkart.in/images/products/overear500_front.jpg',     TRUE,  1),
(15, 9,  'https://kvkart.in/images/products/basscannon.jpg',           TRUE,  1),

-- Mobile Accessories
(16, 10, 'https://kvkart.in/images/products/gan_charger.jpg',          TRUE,  1),

-- Men Footwear
(17, 11, 'https://kvkart.in/images/products/runnerx_side.jpg',         TRUE,  1),
(18, 11, 'https://kvkart.in/images/products/runnerx_sole.jpg',         FALSE, 2),
(19, 12, 'https://kvkart.in/images/products/classic_loafer.jpg',       TRUE,  1),
(20, 13, 'https://kvkart.in/images/products/daily_sneaker.jpg',        TRUE,  1),
(21, 14, 'https://kvkart.in/images/products/trailblazer.jpg',          TRUE,  1),
(22, 15, 'https://kvkart.in/images/products/flip_comfort.jpg',         TRUE,  1),

-- Women Footwear
(23, 16, 'https://kvkart.in/images/products/ballet_flat.jpg',          TRUE,  1),
(24, 17, 'https://kvkart.in/images/products/block_heels.jpg',          TRUE,  1),

-- Men Clothing
(25, 18, 'https://kvkart.in/images/products/oxford_shirt_white.jpg',   TRUE,  1),
(26, 18, 'https://kvkart.in/images/products/oxford_shirt_blue.jpg',    FALSE, 2),
(27, 19, 'https://kvkart.in/images/products/chinos_khaki.jpg',         TRUE,  1),
(28, 20, 'https://kvkart.in/images/products/dryfit_tee.jpg',           TRUE,  1),

-- Women Clothing
(29, 21, 'https://kvkart.in/images/products/floral_kurti.jpg',         TRUE,  1),
(30, 22, 'https://kvkart.in/images/products/denim_jacket.jpg',         TRUE,  1),
(31, 23, 'https://kvkart.in/images/products/maxi_dress.jpg',           TRUE,  1),

-- Accessories
(32, 24, 'https://kvkart.in/images/products/analog_watch.jpg',         TRUE,  1),
(33, 25, 'https://kvkart.in/images/products/laptop_backpack.jpg',      TRUE,  1),
(34, 25, 'https://kvkart.in/images/products/laptop_backpack_open.jpg', FALSE, 2),
(35, 26, 'https://kvkart.in/images/products/sunglasses_cateye.jpg',    TRUE,  1),

-- Home & Kitchen
(36, 27, 'https://kvkart.in/images/products/airfryer_front.jpg',       TRUE,  1),
(37, 27, 'https://kvkart.in/images/products/airfryer_open.jpg',        FALSE, 2),
(38, 28, 'https://kvkart.in/images/products/electric_kettle.jpg',      TRUE,  1),
(39, 29, 'https://kvkart.in/images/products/mixer_grinder.jpg',        TRUE,  1),
(40, 30, 'https://kvkart.in/images/products/bamboo_lamp.jpg',          TRUE,  1),

-- Books
(41, 31, 'https://kvkart.in/images/products/mastering_python.jpg',     TRUE,  1),
(42, 32, 'https://kvkart.in/images/products/startup_way.jpg',          TRUE,  1),
(43, 33, 'https://kvkart.in/images/products/indian_art.jpg',           TRUE,  1),

-- Sports & Fitness
(44, 34, 'https://kvkart.in/images/products/yoga_mat.jpg',             TRUE,  1),
(45, 35, 'https://kvkart.in/images/products/resistance_bands.jpg',     TRUE,  1),
(46, 36, 'https://kvkart.in/images/products/dumbbells_5kg.jpg',        TRUE,  1),
(47, 37, 'https://kvkart.in/images/products/hydration_pack.jpg',       TRUE,  1);
