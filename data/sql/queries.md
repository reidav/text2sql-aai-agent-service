# Database Queries

## Retrieve all securities
```sql
SELECT * FROM securities;
```

## Retrieve portfolios managed by a specific manager
```sql
SELECT * FROM portfolios WHERE manager_id = 101;
```

## Retrieve trades for a specific security
```sql
SELECT * FROM trades WHERE security_id = 1;
```

## Retrieve trades within a specific date range
```sql
SELECT * FROM trades 
WHERE trade_date BETWEEN '2023-01-15' AND '2023-01-17';
```

## Retrieve total trade value by portfolio
```sql
SELECT 
    portfolio_id, 
    SUM(quantity * price) AS total_trade_value 
FROM trades 
GROUP BY portfolio_id;
```

## Retrieve latest market data for a specific security
```sql
SELECT * FROM market_data 
WHERE security_id = 1 
ORDER BY price_date DESC 
LIMIT 1;
```

## Retrieve total trades by portfolio
```sql
SELECT 
    p.portfolio_id, 
    p.portfolio_name, 
    COUNT(t.trade_id) AS total_trades 
FROM portfolios p
LEFT JOIN trades t ON p.portfolio_id = t.portfolio_id
GROUP BY p.portfolio_id, p.portfolio_name;
```

## Retrieve portfolio performance
```sql
SELECT * FROM portfolio_performance;
```

## Retrieve average commission from trades
```sql
SELECT AVG(commission) AS average_commission 
FROM trades;
```