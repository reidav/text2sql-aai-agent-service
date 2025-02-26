CREATE TABLE stocks (
    stock_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    exchange_id INTEGER REFERENCES exchanges(exchange_id),
    stock_type VARCHAR(50),
    listing_date DATE,
    delisting_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE companies (
    company_id INT PRIMARY KEY,
    name VARCHAR(200),
    ticker_symbol VARCHAR(20),
    isin VARCHAR(12),
    sector VARCHAR(100),
    industry VARCHAR(100),
    founded_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE exchanges (
    exchange_id INT PRIMARY KEY,
    name VARCHAR(100),
    country_code VARCHAR(3),
    timezone VARCHAR(50),
    operating_hours VARCHAR(100),
    created_at TIMESTAMP
);

CREATE TABLE stock_prices (
    price_id INT PRIMARY KEY,
    stock_id INTEGER REFERENCES stocks(stock_id),
    date DATE,
    open_price DECIMAL(15,2),
    high_price DECIMAL(15,2),
    low_price DECIMAL(15,2),
    close_price DECIMAL(15,2),
    volume BIGINT,
    created_at TIMESTAMP
);