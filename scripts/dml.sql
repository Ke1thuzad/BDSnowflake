COPY mock_data FROM '/data/MOCK_DATA.csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (1).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (2).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (3).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (4).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (5).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (6).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (7).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (8).csv' WITH (FORMAT CSV, HEADER TRUE);
COPY mock_data FROM '/data/MOCK_DATA (9).csv' WITH (FORMAT CSV, HEADER TRUE);

INSERT INTO dim_customers (
    customer_first_name, customer_last_name, customer_age,
    customer_email, customer_country, customer_postal_code,
    customer_pet_type, customer_pet_name, customer_pet_breed, pet_category
)
SELECT
    customer_first_name, customer_last_name, customer_age,
    customer_email, customer_country, customer_postal_code,
    customer_pet_type, customer_pet_name, customer_pet_breed, pet_category
FROM mock_data;

INSERT INTO dim_products (
    product_name, product_category, product_price, product_quantity,
    product_weight, product_color, product_size, product_brand,
    product_material, product_description, product_rating,
    product_reviews, product_release_date, product_expiry_date
)
SELECT
    product_name, product_category, product_price, product_quantity,
    product_weight, product_color, product_size, product_brand,
    product_material, product_description, product_rating,
    product_reviews, product_release_date, product_expiry_date
FROM mock_data;

INSERT INTO dim_sellers (
    seller_first_name, seller_last_name, seller_email,
    seller_country, seller_postal_code
)
SELECT
    seller_first_name, seller_last_name, seller_email,
    seller_country, seller_postal_code
FROM mock_data;

INSERT INTO dim_stores (
    store_name, store_location, store_city, store_state,
    store_country, store_phone, store_email
)
SELECT
    store_name, store_location, store_city, store_state,
    store_country, store_phone, store_email
FROM mock_data;

INSERT INTO dim_suppliers (
    supplier_name, supplier_contact, supplier_email, supplier_phone,
    supplier_address, supplier_city, supplier_country
)
SELECT
    supplier_name, supplier_contact, supplier_email, supplier_phone,
    supplier_address, supplier_city, supplier_country
FROM mock_data;

INSERT INTO fact_sales (
    sale_date, sale_customer_id, sale_seller_id, sale_product_id,
    sale_quantity, sale_total_price
)
SELECT
    sale_date, sale_customer_id, sale_seller_id, sale_product_id,
    sale_quantity, sale_total_price
FROM mock_data;

INSERT INTO dim_countries (name)
SELECT DISTINCT name
FROM (
    SELECT DISTINCT seller_country FROM dim_sellers
    UNION
    SELECT DISTINCT store_country FROM dim_stores
    UNION
    SELECT DISTINCT customer_country FROM dim_customers
    UNION
    SELECT DISTINCT supplier_country FROM dim_suppliers
) AS all_names(name)
WHERE NOT EXISTS (
    SELECT 1 FROM dim_countries cs WHERE cs.name = all_names.name
);

ALTER TABLE dim_sellers ADD COLUMN seller_country_id int;
ALTER TABLE dim_stores   ADD COLUMN store_country_id int;
ALTER TABLE dim_customers ADD COLUMN customer_country_id int;
ALTER TABLE dim_suppliers ADD COLUMN supplier_country_id int;

UPDATE dim_sellers s SET seller_country_id = c.id
FROM dim_countries c WHERE s.seller_country = c.name;

UPDATE dim_stores s SET store_country_id = c.id
FROM dim_countries c WHERE s.store_country = c.name;

UPDATE dim_customers c SET customer_country_id = ctry.id
FROM dim_countries ctry WHERE c.customer_country = ctry.name;

UPDATE dim_suppliers s SET supplier_country_id = c.id
FROM dim_countries c WHERE s.supplier_country = c.name;

ALTER TABLE dim_sellers ALTER COLUMN seller_country_id SET NOT NULL;
ALTER TABLE dim_stores   ALTER COLUMN store_country_id SET NOT NULL;
ALTER TABLE dim_customers ALTER COLUMN customer_country_id SET NOT NULL;
ALTER TABLE dim_suppliers ALTER COLUMN supplier_country_id SET NOT NULL;

ALTER TABLE dim_sellers ADD CONSTRAINT fk_seller_country_id
    FOREIGN KEY (seller_country_id) REFERENCES dim_countries(id);
ALTER TABLE dim_stores ADD CONSTRAINT fk_store_country_id
    FOREIGN KEY (store_country_id) REFERENCES dim_countries(id);
ALTER TABLE dim_customers ADD CONSTRAINT fk_customer_country_id
    FOREIGN KEY (customer_country_id) REFERENCES dim_countries(id);
ALTER TABLE dim_suppliers ADD CONSTRAINT fk_supplier_country_id
    FOREIGN KEY (supplier_country_id) REFERENCES dim_countries(id);

ALTER TABLE dim_sellers   DROP COLUMN seller_country;
ALTER TABLE dim_stores    DROP COLUMN store_country;
ALTER TABLE dim_customers DROP COLUMN customer_country;
ALTER TABLE dim_suppliers DROP COLUMN supplier_country;

INSERT INTO dim_pet_categories (category)
SELECT DISTINCT pet_category FROM dim_customers WHERE pet_category IS NOT NULL;

ALTER TABLE dim_customers ADD COLUMN pet_category_id INT;

UPDATE dim_customers c
SET pet_category_id = p.id
FROM dim_pet_categories p
WHERE c.pet_category = p.category;

ALTER TABLE dim_customers ALTER COLUMN pet_category_id SET NOT NULL;

ALTER TABLE dim_customers ADD CONSTRAINT fk_dim_pet_categories
    FOREIGN KEY (pet_category_id) REFERENCES dim_pet_categories(id);

ALTER TABLE dim_customers DROP COLUMN pet_category;

UPDATE dim_sellers sl
SET seller_store_id = (
    SELECT s.id
    FROM dim_stores s
    JOIN mock_data md ON md.store_name = s.store_name AND md.store_email = s.store_email
    WHERE md.seller_email = sl.seller_email
    LIMIT 1
);

UPDATE dim_products p
SET product_supplier_id = (
    SELECT s.id
    FROM dim_suppliers s
    JOIN mock_data md ON md.supplier_name = s.supplier_name AND md.supplier_email = s.supplier_email
    WHERE md.product_brand = p.product_brand
      AND md.product_category = p.product_category
      AND md.product_name = p.product_name
    LIMIT 1
);