CREATE DATABASE zomato_db;
USE zomato_db;

CREATE TABLE main_restaurant_table (
    RestaurantID INT,
    RestaurantName VARCHAR(255),
    CountryCode INT,
    City VARCHAR(100),
    Address VARCHAR(500),
    Locality VARCHAR(255),
    LocalityVerbose VARCHAR(255),
    Longitude DOUBLE,
    Latitude DOUBLE,
    Cuisines VARCHAR(255),
    Currency VARCHAR(50),
    Has_Table_booking VARCHAR(10),
    Has_Online_delivery VARCHAR(10),
    Is_delivering_now VARCHAR(10),
    Switch_to_order_menu VARCHAR(10),
    Price_range INT,
    Votes INT,
    Average_Cost_for_two INT,
    Rating DOUBLE,
    Datekey_Opening VARCHAR(50)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'D:\\EXCELR\\DATA ANALYST\\PROJECT\\Zomato.csv'
INTO TABLE main_restaurant_table
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


SELECT COUNT(*) FROM main_restaurant_table;

SELECT * FROM main_restaurant_table;

#---------------------------------------------------------------TASK 1 ---------------------------------------------------------------------#
#-----------------------------------------------------------Country Mapping ----------------------------------------------------------------#

USE zomato_db;

CREATE TABLE IF NOT EXISTS country_table (
    CountryCode INT PRIMARY KEY,
    CountryName VARCHAR(100)
);

INSERT INTO country_table (CountryCode, CountryName) VALUES
(1, 'India'),
(14, 'Australia'),
(30, 'Brazil'),
(37, 'Canada'),
(94, 'Indonesia'),
(148, 'New Zealand'),
(162, 'Phillipines'),
(166, 'Qatar'),
(184, 'Singapore'),
(189, 'South Africa'),
(191, 'Sri Lanka'),
(208, 'Turkey'),
(214, 'UAE'),
(215, 'United Kingdom'),
(216, 'United States');

SELECT * FROM COUNTRY_TABLE;

SELECT
m.RestaurantID,
m.RestaurantName,
c.CountryName,
m.City,
m.Rating
FROM main_restaurant_table m JOIN country_table c on m.CountryCode = c.CountryCode
LIMIT 15;

# Distinct Countries
SELECT DISTINCT c.CountryName 
FROM main_restaurant_table m 
JOIN country_table c on m.CountryCode = c.CountryCode;



#---------------------------------------------------------------TASK 2 --------------------------------------------------------------------#
#-----------------------------------------------------------Calendar Table ----------------------------------------------------------------#

SELECT 
    Datekey_Opening,
    
    -- 1. Year (वर्ष)
    YEAR(REPLACE(Datekey_Opening, '_', '-')) AS Year,
    
    -- 2. Month No (महिना नंबर: 1, 2, 3...)
    MONTH(REPLACE(Datekey_Opening, '_', '-')) AS MonthNo,
    
    -- 3. Month Name (महिन्याचे नाव: January, February...)
    MONTHNAME(REPLACE(Datekey_Opening, '_', '-')) AS MonthName,
    
    -- 4. Quarter (Q1, Q2, Q3, Q4)
    CONCAT('Q', QUARTER(REPLACE(Datekey_Opening, '_', '-'))) AS Quarter,
    
    -- 5. YearMonth (YYYY-MMM format: 2019-Jan)
    DATE_FORMAT(REPLACE(Datekey_Opening, '_', '-'), '%Y-%b') AS YearMonth,
    
    -- 6. Weekday No (वार क्रमांक: Sunday=1, Monday=2...)
    DAYOFWEEK(REPLACE(Datekey_Opening, '_', '-')) AS WeekdayNo,
    
    -- 7. Weekday Name (वाराचे नाव: Monday, Tuesday...)
    DAYNAME(REPLACE(Datekey_Opening, '_', '-')) AS WeekdayName,
    
    -- 8. Financial Month (Financial Year: April=1 ते March=12)
    CASE 
        WHEN MONTH(REPLACE(Datekey_Opening, '_', '-')) >= 4 
        THEN MONTH(REPLACE(Datekey_Opening, '_', '-')) - 3
        ELSE MONTH(REPLACE(Datekey_Opening, '_', '-')) + 9
    END AS Financial_Month,
    
    -- 9. Financial Quarter (Financial Year: Q1=Apr-Jun, Q2=Jul-Sep...)
    CASE 
        WHEN MONTH(REPLACE(Datekey_Opening, '_', '-')) BETWEEN 4 AND 6 THEN 'FQ-1'
        WHEN MONTH(REPLACE(Datekey_Opening, '_', '-')) BETWEEN 7 AND 9 THEN 'FQ-2'
        WHEN MONTH(REPLACE(Datekey_Opening, '_', '-')) BETWEEN 10 AND 12 THEN 'FQ-3'
        ELSE 'FQ-4'
    END AS Financial_Quarter

FROM main_restaurant_table
LIMIT 15;

#----------------------------------------------------------- TASK 3 ----------------------------------------------------------------#

#----------------------------------------------- 1. Country-wise Restaurant Count --------------------------------------------------#
SELECT 
    c.CountryName,
    COUNT(m.RestaurantID) AS Total_Restaurants
FROM main_restaurant_table m
JOIN country_table c ON m.CountryCode = c.CountryCode
GROUP BY c.CountryName
ORDER BY Total_Restaurants DESC;

#----------------------------------------------- 2. Top 10 Cities with Highest Restaurants ------------------------------------------#
SELECT 
    m.City,
    c.CountryName,
    COUNT(m.RestaurantID) AS Total_Restaurants
FROM main_restaurant_table m
JOIN country_table c ON m.CountryCode = c.CountryCode
GROUP BY m.City, c.CountryName
ORDER BY Total_Restaurants DESC
LIMIT 10;



#----------------------------------------------------------- TASK 4 ----------------------------------------------------------------#


#-------------------------------------------------------- YEAR WISE OPENING ----------------------------------------------------------#

SELECT 
    YEAR(REPLACE(Datekey_Opening, '_', '-')) AS Opening_Year,
    COUNT(RestaurantID) AS Total_Restaurants_Opened
FROM main_restaurant_table
GROUP BY Opening_Year
ORDER BY Opening_Year ASC;

#-------------------------------------------------------- Quarter WISE OPENING ----------------------------------------------------------#

SELECT 
    CONCAT('Q', QUARTER(REPLACE(Datekey_Opening, '_', '-'))) AS Quarter,
    COUNT(RestaurantID) AS Total_Restaurants_Opened
FROM main_restaurant_table
GROUP BY Quarter
ORDER BY Quarter ASC;


#---------------------------------------------------------- Month WISE OPENING ----------------------------------------------------------#

SELECT 
    MONTHNAME(REPLACE(Datekey_Opening, '_', '-')) AS Month_Name,
    COUNT(RestaurantID) AS Total_Restaurants_Opened
FROM main_restaurant_table
GROUP BY MONTH(REPLACE(Datekey_Opening, '_', '-')), Month_Name
ORDER BY MONTH(REPLACE(Datekey_Opening, '_', '-')) ASC;

#----------------------------------------------------------------- TASK 5 ---------------------------------------------------------------#


#------------------------------------------------ Restaurants Distrubution by Ratings Buckets---------------------------------------------#

SELECT 
    CASE 
        WHEN Rating >= 4.5 THEN '4.5 - 5.0 (Excellent)'
        WHEN Rating >= 4.0 THEN '4.0 - 4.4 (Very Good)'
        WHEN Rating >= 3.5 THEN '3.5 - 3.9 (Good)'
        WHEN Rating >= 3.0 THEN '3.0 - 3.4 (Average)'
        WHEN Rating >= 2.5 THEN '2.5 - 2.9 (Poor)'
        ELSE 'Below 2.5 / Unrated'
    END AS Rating_Bucket,
    COUNT(RestaurantID) AS Total_Restaurants
FROM main_restaurant_table
GROUP BY Rating_Bucket
ORDER BY Total_Restaurants DESC;


#----------------------------------------------------------------- TASK 6 ---------------------------------------------------------------#


#---------------------------------------------------- Restaurant Count by Range Buckets -------------------------------------------------#


SELECT 
    CASE 
        WHEN Average_Cost_for_two <= 500 THEN '0 - 500 (Budget)'
        WHEN Average_Cost_for_two BETWEEN 501 AND 1000 THEN '501 - 1000 (Medium)'
        WHEN Average_Cost_for_two BETWEEN 1001 AND 2000 THEN '1001 - 2000 (High)'
        ELSE '2000+ (Premium/Luxury)'
    END AS Price_Bucket,
    COUNT(RestaurantID) AS Total_Restaurants
FROM main_restaurant_table
GROUP BY Price_Bucket
ORDER BY Total_Restaurants DESC;

#----------------------------------------------------------------- TASK 7 ---------------------------------------------------------------#


#------------------------------------------------ Percentage of Restaurants with Table Booking -------------------------------------------#

SELECT 
    Has_Table_booking,
    COUNT(RestaurantID) AS Total_Restaurants,
    ROUND((COUNT(RestaurantID) * 100.0) / (SELECT COUNT(*) FROM main_restaurant_table), 2) AS Percentage
FROM main_restaurant_table
GROUP BY Has_Table_booking;


#----------------------------------------------------------------- TASK 8 ---------------------------------------------------------------#


#------------------------------------------------ Percentage of Restaurants with Online Delivery -------------------------------------------#

SELECT 
    Has_Online_delivery,
    COUNT(RestaurantID) AS Total_Restaurants,
    ROUND((COUNT(RestaurantID) * 100.0) / (SELECT COUNT(*) FROM main_restaurant_table), 2) AS Percentage
FROM main_restaurant_table
GROUP BY Has_Online_delivery;


#----------------------------------------------------------------- TASK 9 ---------------------------------------------------------------#


#-------------------------------------------------------------- Top 10 Cuisines ---------------------------------------------------------#

SELECT 
    Cuisines,
    COUNT(RestaurantID) AS Total_Restaurants
FROM main_restaurant_table
GROUP BY Cuisines
ORDER BY Total_Restaurants DESC
LIMIT 10;


#----------------------------------------------------------- City-Wise Average Rtings ------------------------------------------------------#


SELECT 
    City,
    COUNT(RestaurantID) AS Total_Restaurants,
    ROUND(AVG(Rating), 2) AS Avg_Rating
FROM main_restaurant_table
GROUP BY City
HAVING Total_Restaurants >= 10
ORDER BY Avg_Rating DESC;

#-------------------------------------------------------------- City and Rating Bucket ---------------------------------------------------------#


SELECT 
    City,
    CASE 
        WHEN Rating >= 4.0 THEN 'High Rating (4.0+)'
        WHEN Rating >= 3.0 THEN 'Average Rating (3.0-3.9)'
        ELSE 'Low Rating (< 3.0)'
    END AS Rating_Category,
    COUNT(RestaurantID) AS Total_Restaurants
FROM main_restaurant_table
GROUP BY City, Rating_Category
ORDER BY City;

-- =========================================================   END   =========================================================================