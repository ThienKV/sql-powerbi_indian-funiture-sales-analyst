USE NewDatabase;

---- A. DATA UNDERSTANDING
--- 1. CHECK TABLE FORMAT
SELECT TOP 10 * FROM order_;
SELECT TOP 10 * FROM order_details;
SELECT TOP 10 * FROM sales_target;

--- 2. CHECK INFO TABLE - DATA TYPE
SELECT 
	TABLE_NAME,
	COLUMN_NAME,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS -- Note: Month_of_Order_Date đang là nvarchar

--- 3. CHECK DISTINCT COUNT
SELECT COUNT(*) FROM dbo.order_;
SELECT COUNT(*) FROM dbo.order_details;
-- distinct order
SELECT COUNT(DISTINCT Order_ID) FROM dbo.order_;
SELECT COUNT(DISTINCT Order_ID) FROM dbo.order_details; -- Note: Nếu 2 số countdistinct khác thì đang có vấn đề về join


---- B. DATA CLEANNING & VALIDATION
--- 1.  MISSING VALUES
SELECT *
FROM order_
WHERE
	[Order_ID]	IS NULL OR
    [Order_Date] IS NULL OR
    [CustomerName] IS NULL OR
    [State] IS NULL OR
    [City] IS NULL;

SELECT *
FROM order_details
WHERE
	 [Order_ID] IS NULL OR
     [Amount] IS NULL OR
     [Profit] IS NULL OR
     [Quantity] IS NULL OR
     [Category] IS NULL OR
     [Sub_Category] IS NULL;

--- 2. CHECK OUTLIERS
SELECT *
FROM order_details
WHERE 
    Amount < 0 OR
    Profit < 0 OR --- Note: Profit đang có giá trị âm nhưng lợi nhuận có thể âm
    Quantity < 0;

SELECT * 
FROM sales_target
WHERE
    Target < 0;

SELECT TOP 10 *
FROM dbo.order_details
ORDER BY Amount DESC;

--- 3. CHECK DUPLICATE
SELECT Order_ID, COUNT(Order_ID) AS COUNTID
FROM order_
GROUP BY Order_ID
HAVING COUNT(Order_ID) > 2;

SELECT Order_ID, COUNT(Order_ID) AS COUNTID2
FROM order_details
GROUP BY Order_ID
HAVING COUNT(Order_ID) > 2;



---- C. DATA FINAL
--- 1. DATA ORDER WITH DETAILS
SELECT DISTINCT
    o.Order_ID,
    TRY_CONVERT(date, o.Order_Date) as Order_Date,
    o.CustomerName,
    o.State,
    o.City,
    od.Amount,
    od.Profit,
    od.Quantity,
    od.Category,
    od.Sub_Category
FROM dbo.order_ o
LEFT JOIN dbo.order_details od 
    ON o.Order_ID = od.Order_ID

--- 2. DATA TARGET
SELECT *
FROM sales_target

--- 3. DATA COHORT
SELECT CustomerName,Order_Date,SUM(Amount) AS Amount
FROM 
( 
SELECT DISTINCT
    o.Order_ID,
    TRY_CONVERT(date, o.Order_Date) as Order_Date,
    o.CustomerName,
    o.State,
    o.City,
    od.Amount,
    od.Profit,
    od.Quantity,
    od.Category,
    od.Sub_Category
FROM dbo.order_ o
LEFT JOIN dbo.order_details od 
    ON o.Order_ID = od.Order_ID
) AS tb
GROUP BY CustomerName,Order_Date
