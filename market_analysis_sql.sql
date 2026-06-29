--Q1.Which date sample saw the overall trading volume most?
select date,sum(volume) from market_table
group by date 
order by sum(volume) desc limit 5;
--Q2.Top 5 companies with most trading?
select symbol,ROUND(avg(volume),2) as average_volume
from market_table group by symbol
order by average_volume desc limit 5;
--Q3.every year most trade company
WITH YearlyVolumes AS (
    SELECT 
        EXTRACT(YEAR FROM date) AS saal, 
        symbol, 
        SUM(volume) AS total_volume
    FROM market_table
    GROUP BY EXTRACT(YEAR FROM date), symbol
),
RankedVolumes AS (
    SELECT 
        saal, 
        symbol, 
        total_volume,
        ROW_NUMBER() OVER(PARTITION BY saal ORDER BY total_volume DESC) AS rank
    FROM YearlyVolumes
)
SELECT saal, symbol, total_volume
FROM RankedVolumes
WHERE rank = 1
ORDER BY saal;
--Q4.Kon si company kis time par sabse syada volatile thi?
WITH VolatilityTable AS (
    SELECT 
        EXTRACT(YEAR FROM date) AS saal,
        date,
        symbol,
        (high - low) AS price_difference,
        -- Volatility ke percentage ke liye: (High - Low) / Low * 100
        ROUND(((high - low) / low) * 100, 2) AS volatility_percentage
    FROM market_table
),
RankedVolatility AS (
    SELECT 
        saal,
        date,
        symbol,
        price_difference,
        volatility_percentage,
        ROW_NUMBER() OVER(PARTITION BY saal ORDER BY volatility_percentage DESC) AS rank
    FROM VolatilityTable
)
SELECT saal, date, symbol, price_difference, volatility_percentage || '%' AS volatility
FROM RankedVolatility
WHERE rank = 1
ORDER BY saal;
--Q5.AAPL company ka trend
SELECT 
    EXTRACT(YEAR FROM date) AS saal,
    EXTRACT(MONTH FROM date) AS mahina,
    symbol,
    ROUND(AVG(close), 2) AS avg_close_price
FROM market_table
WHERE symbol = 'AAPL'
GROUP BY EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date), symbol
ORDER BY saal, mahina;
--Q6.Moving AVERAGE
SELECT 
   date,
   symbol,
   close,
   ROUND(AVG(close) OVER(PARTITION BY symbol ORDER BY date ROWS between 6 preceding and current row),2) as moving_avg7_days,
   ROUND(AVG(close) OVER(PARTITION BY symbol ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT row),2) as moving_avg30_days
from market_table
where symbol='AAPL'
order by date;