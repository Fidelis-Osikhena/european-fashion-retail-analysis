CREATE TABLE channels (
    channel VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
);

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    country VARCHAR(100),
    age_range VARCHAR(20),
    signup_date DATE
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    brand VARCHAR(100),
    color VARCHAR(50),
    size VARCHAR(20),
    catalog_price NUMERIC(10, 2),
    cost_price NUMERIC(10, 2),
    gender VARCHAR(20)
);

CREATE TABLE campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name VARCHAR(255),
    start_date DATE,
    end_date DATE,
    channel VARCHAR(50),
    discount_type VARCHAR(50),
    discount_value NUMERIC(10, 2),

    CONSTRAINT fk_campaign_channel
        FOREIGN KEY (channel)
        REFERENCES channels(channel)
);

CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    channel VARCHAR(50),
    discounted INTEGER,
    total_amount NUMERIC(12, 2),
    sale_date DATE,
    customer_id INTEGER,
    country VARCHAR(100),

    CONSTRAINT fk_sale_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_sale_channel
        FOREIGN KEY (channel)
        REFERENCES channels(channel)
);

CREATE TABLE salesitems (
    item_id INTEGER PRIMARY KEY,
    sale_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    original_price NUMERIC(10, 2),
    unit_price NUMERIC(10, 2),
    discount_applied INTEGER,
    discount_percent NUMERIC(10, 4),
    discounted_item_total NUMERIC(12, 2),
    sale_date DATE,
    channel VARCHAR(50),
    channel_campaigns VARCHAR(255),

    CONSTRAINT fk_item_sale
        FOREIGN KEY (sale_id)
        REFERENCES sales(sale_id),

    CONSTRAINT fk_item_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT fk_item_channel
        FOREIGN KEY (channel)
        REFERENCES channels(channel)
);

CREATE TABLE stock (
    country VARCHAR(100),
    product_id INTEGER,
    stock_quantity INTEGER,

    PRIMARY KEY (country, product_id),

    CONSTRAINT fk_stock_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);