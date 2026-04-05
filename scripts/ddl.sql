CREATE TABLE public.mock_data (
    id int4 NULL,
    customer_first_name varchar(50) NULL,
    customer_last_name varchar(50) NULL,
    customer_age int4 NULL,
    customer_email varchar(50) NULL,
    customer_country varchar(50) NULL,
    customer_postal_code varchar(50) NULL,
    customer_pet_type varchar(50) NULL,
    customer_pet_name varchar(50) NULL,
    customer_pet_breed varchar(50) NULL,
    seller_first_name varchar(50) NULL,
    seller_last_name varchar(50) NULL,
    seller_email varchar(50) NULL,
    seller_country varchar(50) NULL,
    seller_postal_code varchar(50) NULL,
    product_name varchar(50) NULL,
    product_category varchar(50) NULL,
    product_price float4 NULL,
    product_quantity int4 NULL,
    sale_date varchar(50) NULL,
    sale_customer_id int4 NULL,
    sale_seller_id int4 NULL,
    sale_product_id int4 NULL,
    sale_quantity int4 NULL,
    sale_total_price float4 NULL,
    store_name varchar(50) NULL,
    store_location varchar(50) NULL,
    store_city varchar(50) NULL,
    store_state varchar(50) NULL,
    store_country varchar(50) NULL,
    store_phone varchar(50) NULL,
    store_email varchar(50) NULL,
    pet_category varchar(50) NULL,
    product_weight float4 NULL,
    product_color varchar(50) NULL,
    product_size varchar(50) NULL,
    product_brand varchar(50) NULL,
    product_material varchar(50) NULL,
    product_description varchar(1024) NULL,
    product_rating float4 NULL,
    product_reviews int4 NULL,
    product_release_date varchar(50) NULL,
    product_expiry_date varchar(50) NULL,
    supplier_name varchar(50) NULL,
    supplier_contact varchar(50) NULL,
    supplier_email varchar(50) NULL,
    supplier_phone varchar(50) NULL,
    supplier_address varchar(50) NULL,
    supplier_city varchar(50) NULL,
    supplier_country varchar(50) NULL
);

CREATE TABLE dim_customers (
    id serial PRIMARY KEY,
    customer_first_name varchar(50) NULL,
    customer_last_name varchar(50) NULL,
    customer_age int4 NULL,
    customer_email varchar(50) NULL,
    customer_country varchar(50) NULL,
    customer_postal_code varchar(50) NULL,
    customer_pet_type varchar(50) NULL,
    customer_pet_name varchar(50) NULL,
    customer_pet_breed varchar(50) NULL,
    pet_category varchar(50) NULL
);

CREATE TABLE dim_stores (
    id serial PRIMARY KEY,
    store_name varchar(50) NULL,
    store_location varchar(50) NULL,
    store_city varchar(50) NULL,
    store_state varchar(50) NULL,
    store_country varchar(50) NULL,
    store_phone varchar(50) NULL,
    store_email varchar(50) NULL
);

CREATE TABLE dim_suppliers (
    id serial PRIMARY KEY,
    supplier_name varchar(50) NULL,
    supplier_contact varchar(50) NULL,
    supplier_email varchar(50) NULL,
    supplier_phone varchar(50) NULL,
    supplier_address varchar(50) NULL,
    supplier_city varchar(50) NULL,
    supplier_country varchar(50) NULL
);

CREATE TABLE dim_sellers (
    id serial PRIMARY KEY,
    seller_first_name varchar(50) NULL,
    seller_last_name varchar(50) NULL,
    seller_email varchar(50) NULL,
    seller_country varchar(50) NULL,
    seller_postal_code varchar(50) NULL,
    seller_store_id int4 NULL REFERENCES dim_stores
);

CREATE TABLE dim_products (
    id serial PRIMARY KEY,
    product_name varchar(50) NULL,
    product_category varchar(50) NULL,
    product_price float4 NULL,
    product_quantity int4 NULL,
    product_weight float4 NULL,
    product_color varchar(50) NULL,
    product_size varchar(50) NULL,
    product_brand varchar(50) NULL,
    product_material varchar(50) NULL,
    product_description varchar(1024) NULL,
    product_rating float4 NULL,
    product_reviews int4 NULL,
    product_release_date varchar(50) NULL,
    product_expiry_date varchar(50) NULL,
    product_supplier_id int4 NULL REFERENCES dim_suppliers
);

CREATE TABLE fact_sales (
    id serial PRIMARY KEY,
    sale_date varchar(50) NULL,
    sale_customer_id int4 NULL REFERENCES dim_customers,
    sale_seller_id int4 NULL REFERENCES dim_sellers,
    sale_product_id int4 NULL REFERENCES dim_products,
    sale_quantity int4 NULL,
    sale_total_price float4 NULL
);

CREATE TABLE dim_countries (
    id serial PRIMARY KEY,
    name varchar(50) NOT NULL UNIQUE
);

CREATE TABLE dim_pet_categories (
    id serial PRIMARY KEY,
    category varchar(50)
);